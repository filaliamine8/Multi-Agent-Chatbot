from llm_provider import llm_provider
from tools.db_search import get_order_status
import json

class SupportAgent:
    def __init__(self):
        self.system_prompt = """
        You are a Customer Support Agent.
        Your goal is to help with order status, returns, and technical issues.
        
        If the user provides an Order ID (number), use the context below to give them the status.
        If they don't provide an ID, ask for it politely.
        
        Order Context:
        {order_info}
        """
        
    def handle_message(self, user_message):
        # Very simple extraction of numbers for demo purposes
        # In a real agent, the LLM would extract this via tool calling
        import re
        order_ids = re.findall(r'\b\d+\b', user_message)
        
        order_info = "No specific order found in message."
        if order_ids:
            # Check the first number found
            status = get_order_status(order_ids[0])
            if status:
                order_info = json.dumps(status, indent=2)
            else:
                order_info = f"Order #{order_ids[0]} not found."
        
        formatted_prompt = self.system_prompt.replace("{order_info}", order_info)
        
        if not llm_provider:
             return f"Support Agent here. I see you're asking about order data: {order_info}"
             
        return llm_provider.generate(formatted_prompt, user_message)
