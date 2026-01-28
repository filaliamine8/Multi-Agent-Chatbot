from llm_provider import llm_provider
from tools.db_search import search_products
import json

class SalesAgent:
    def __init__(self):
        self.system_prompt = """
        You are a Sales Agent for an electronics store.
        Your goal is to sell products and answer questions about them.
        You have access to the product catalog below.
        
        Catalog Context:
        {products_json}
        
        Instructions:
        - Be enthusiastic and helpful.
        - If a user asks for a product we have, mention its price and stock.
        - If we don't have it, recommend a similar item from the catalog.
        - If the user uses a promo code, acknowledge it (just simulate checking it).
        """
        
    def handle_message(self, user_message):
        # 1. Fetch products to give context to the LLM
        # In a real app, we might use RAG here, but for now we dump the whole small catalog
        all_products = search_products() 
        products_json = json.dumps(all_products, indent=2)
        
        formatted_prompt = self.system_prompt.replace("{products_json}", products_json)
        
        if not llm_provider:
             return f"I am the Sales Agent. I see we have: {', '.join([p['name'] for p in all_products])}. How can I help?"
             
        return llm_provider.generate(formatted_prompt, user_message)
