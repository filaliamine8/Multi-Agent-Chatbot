from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from datetime import datetime
import os

# Import Agents
from agents.orchestrator import Orchestrator
from agents.sales import SalesAgent
from agents.support import SupportAgent
from agents.supervisor import SupervisorAgent
from agents.baseline import BaselineAgent

app = Flask(__name__, static_folder='.')
CORS(app)

# Initialize Agents
try:
    orchestrator = Orchestrator()
    sales_agent = SalesAgent()
    support_agent = SupportAgent()
    supervisor = SupervisorAgent()
    baseline_agent = BaselineAgent()
    print("Agents initialized successfully.")
except Exception as e:
    print(f"Error initializing agents: {e}")

message_history = []

@app.route('/')
def index():
    return send_from_directory('.', 'index.html')

@app.route('/<path:path>')
def serve_static(path):
    return send_from_directory('.', path)

@app.route('/api/chat', methods=['POST'])
def chat():
    data = request.get_json()
    user_message = data.get('message', '')
    mode = data.get('mode', 'multi') # 'multi' or 'mono'
    
    if not user_message:
        return jsonify({'error': 'No message provided'}), 400
    
    # Trace log to send back to UI
    trace_log = []
    response_text = ""
    
    start_time = datetime.now()
    
    try:
        if mode == 'mono':
            trace_log.append(f"[{datetime.now().strftime('%H:%M:%S')}] Mode: MONO-AGENT")
            trace_log.append(f"Calling Baseline Agent...")
            response_text = baseline_agent.handle_message(user_message)
            trace_log.append(f"Baseline Agent replied.")
            
        else: # Multi-Agent
            trace_log.append(f"[{datetime.now().strftime('%H:%M:%S')}] Mode: MULTI-AGENT")
            
            # 1. Orchestration
            trace_log.append("Orchestrator: Analyzing intent...")
            intent = orchestrator.decide_agent(user_message)
            trace_log.append(f"Orchestrator: Intent detected -> {intent}")
            
            # 2. Delegation
            raw_response = ""
            if intent == 'SALES':
                trace_log.append("Delegating to Sales Agent...")
                raw_response = sales_agent.handle_message(user_message)
            elif intent == 'SUPPORT':
                trace_log.append("Delegating to Support Agent...")
                raw_response = support_agent.handle_message(user_message)
            else:
                # Chit Chat fallback
                trace_log.append("Handling as Chit-Chat...")
                raw_response = "I am the Orchestrator. I can help specific queries about Sales or Support. For general chat, I am limited."
                if hasattr(orchestrator, 'handle_message'):
                     # If orchestrator has a chat capability
                     pass
                
            trace_log.append(f"Agent Raw Response: {raw_response[:50]}...")
            
            # 3. Supervision
            trace_log.append("Supervisor: Reviewing response for quality...")
            critique = supervisor.review(user_message, raw_response)
            
            if critique == "APPROVED":
                response_text = raw_response
                trace_log.append("Supervisor: Response APPROVED.")
            else:
                response_text = critique
                trace_log.append("Supervisor: Response REVISED.")
                
    except Exception as e:
        trace_log.append(f"ERROR: {str(e)}")
        response_text = "Internal Server Error during agent processing."
        print(f"Error in chat processing: {e}")

    # Store history
    message_history.append({'role': 'user', 'content': user_message, 'timestamp': start_time.isoformat()})
    message_history.append({'role': 'assistant', 'content': response_text, 'timestamp': datetime.now().isoformat()})
    
    return jsonify({
        'response': response_text,
        'trace': trace_log,
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/history', methods=['GET'])
def get_history():
    return jsonify({'messages': message_history})

@app.route('/api/clear', methods=['POST'])
def clear_history():
    global message_history
    message_history = []
    return jsonify({'status': 'cleared'})

if __name__ == '__main__':
    print("Starting Multi-Agent Server on http://localhost:5000")
    app.run(debug=True, port=5000)
