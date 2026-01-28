from llm_provider import llm_provider

class Orchestrator:
    def __init__(self):
        self.system_prompt = """
        You are the Orchestrator of an e-commerce multi-agent system.
        Your job is to analyze the user's message and decide which specialized agent should handle it.
        
        Available Agents:
        1. 'SALES': For buying products, asking about stock, prices, or recommendations.
        2. 'SUPPORT': For checking order status, complaints, returns, or technical issues.
        3. 'CHIT_CHAT': For greetings or general questions not related to the shop.
        
        Output ONLY the agent name (SALES, SUPPORT, or CHIT_CHAT). Do not add any explanation.
        """
        
    def decide_agent(self, user_message):
        if not llm_provider:
            # Fallback mock logic
            msg = user_message.lower()
            if any(w in msg for w in ['buy', 'price', 'cost', 'stock', 'iphone', 'macbook']):
                return 'SALES'
            if any(w in msg for w in ['order', 'status', 'broken', 'return', 'help']):
                return 'SUPPORT'
            return 'CHIT_CHAT'
            
        return llm_provider.generate(self.system_prompt, user_message).strip()
