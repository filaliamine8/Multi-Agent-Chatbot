from llm_provider import llm_provider
from tools.db_search import search_products

class BaselineAgent:
    def __init__(self):
        self.system_prompt = """
        You are a helpful assistant for an e-commerce store.
        You have access to products: {products}
        Answer the user's question directly.
        """
        
    def handle_message(self, user_message):
        products = search_products()
        prompt = self.system_prompt.replace("{products}", str(products))
        
        if not llm_provider:
            return "Baseline Agent: I am a generic chatbot. I try to help with everything at once."
            
        return llm_provider.generate(prompt, user_message)
