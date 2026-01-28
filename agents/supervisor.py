from llm_provider import llm_provider

class SupervisorAgent:
    def __init__(self):
        self.system_prompt = """
        You are the Quality Supervisor.
        Review the Agent's response to the User.
        
        Rules:
        1. If the response is polite and reasonable, output ONLY the word: APPROVED
        2. If the response needs improvement, output ONLY the rewritten response text.
        3. DO NOT provide any explanation, critique, or meta-commentary.
        4. DO NOT say "Here is a better version". Just output the final text.
        """
        
    def review(self, user_message, agent_response):
        if not llm_provider:
            return "APPROVED" # Mock always approves
            
        prompt = f"""
        User said: "{user_message}"
        Agent replied: "{agent_response}"
        
        Action (APPROVED or Rewrite):
        """
        return llm_provider.generate(self.system_prompt, prompt)
