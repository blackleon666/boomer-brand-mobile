"""
BOOMER BRAND ADMIN API SERVER
Bot ile entegre admin paneli için HTTP API
"""

import os
import sys
import json
import logging
from datetime import datetime
from flask import Flask, jsonify, request
from flask_cors import CORS

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

app = Flask(__name__)
CORS(app)

ADMIN_TOKEN = 'boomer-admin-2026'
LOG_FILE = 'logs/admin.log'

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

def require_auth(f):
    def decorated(*args, **kwargs):
        token = request.headers.get('X-Admin-Token')
        if token != ADMIN_TOKEN:
            return jsonify({'error': 'Unauthorized'}), 401
        return f(*args, **kwargs)
    decorated.__name__ = f.__name__
    return decorated

def log_action(action, data=''):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    with open(LOG_FILE, 'a', encoding='utf-8') as f:
        f.write(f'[{timestamp}] {action}: {data}\n')

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'online', 'timestamp': datetime.now().isoformat()})

@app.route('/api/stats', methods=['GET'])
@require_auth
def get_stats():
    try:
        from db.repo import get_stats as bot_get_stats
        stats = bot_get_stats()
        
        stats['uptime'] = os.popen('wmic os get Uptime').read().split()[-1] if os.name == 'nt' else 0
        
        log_action('STATS', 'Fetched stats')
        return jsonify(stats)
    except Exception as e:
        logger.error(f"Stats error: {e}")
        return jsonify({'users': 0, 'products': 0, 'orders': 0, 'complaints': 0, 'uptime': 0})

@app.route('/api/orders', methods=['GET'])
@require_auth
def get_orders():
    try:
        from db.repo import get_all_orders
        orders = get_all_orders()
        log_action('ORDERS', f'Fetched {len(orders)} orders')
        return jsonify({'orders': orders})
    except Exception as e:
        logger.error(f"Orders error: {e}")
        return jsonify({'orders': []})

@app.route('/api/orders/<order_id>/status', methods=['POST'])
@require_auth
def update_order_status(order_id):
    try:
        from db.repo import update_order_status as bot_update
        status = request.json.get('status', 'pending')
        bot_update(order_id, status)
        log_action('ORDER_STATUS', f'{order_id} -> {status}')
        return jsonify({'message': 'Status updated', 'order_id': order_id})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/orders/<order_id>/tracking', methods=['POST'])
@require_auth
def set_tracking(order_id):
    try:
        from db.repo import set_tracking_code
        code = request.json.get('code', '')
        set_tracking_code(order_id, code)
        log_action('TRACKING', f'{order_id} -> {code}')
        return jsonify({'message': 'Tracking code set'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/orders/<order_id>/confirm', methods=['POST'])
@require_auth
def confirm_payment(order_id):
    try:
        from db.repo import confirm_payment as bot_confirm
        bot_confirm(order_id, 'Ödeme onaylandı')
        log_action('PAYMENT_CONFIRM', order_id)
        return jsonify({'message': 'Payment confirmed'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/orders/<order_id>/reject', methods=['POST'])
@require_auth
def reject_payment(order_id):
    try:
        from db.repo import reject_payment as bot_reject
        reason = request.json.get('reason', 'Reddedildi')
        bot_reject(order_id, reason)
        log_action('PAYMENT_REJECT', f'{order_id}: {reason}')
        return jsonify({'message': 'Payment rejected'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/products', methods=['GET'])
@require_auth
def get_products():
    try:
        from db.repo import get_all_products
        products = get_all_products()
        log_action('PRODUCTS', f'Fetched {len(products)} products')
        return jsonify({'products': products})
    except Exception as e:
        logger.error(f"Products error: {e}")
        return jsonify({'products': []})

@app.route('/api/feedbacks', methods=['GET'])
@require_auth
def get_feedbacks():
    try:
        from db.repo import get_new_feedback
        feedbacks = get_new_feedback()
        log_action('FEEDBACKS', f'Fetched {len(feedbacks)} feedbacks')
        return jsonify({'feedbacks': feedbacks})
    except Exception as e:
        return jsonify({'feedbacks': []})

@app.route('/api/logs', methods=['GET'])
@require_auth
def get_logs():
    try:
        if os.path.exists(LOG_FILE):
            with open(LOG_FILE, 'r', encoding='utf-8') as f:
                lines = f.readlines()[-100:]
                logs = [line.strip() for line in lines if line.strip()]
            return jsonify({'logs': logs})
        return jsonify({'logs': []})
    except Exception as e:
        return jsonify({'logs': []})

@app.route('/api/restart', methods=['POST'])
@require_auth
def restart_bot():
    try:
        log_action('RESTART', 'Bot restart requested')
        os.system('taskkill /F /IM python.exe /T' if os.name == 'nt' else 'pkill -f bot.py')
        return jsonify({'message': 'Bot restart initiated'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    os.makedirs('logs', exist_ok=True)
    log_action('SERVER_START', 'Admin API server started')
    print('=' * 50)
    print('   BOOMER BRAND ADMIN API')
    print('   Port: 10000')
    print('   Token: boomer-admin-2026')
    print('=' * 50)
    app.run(host='0.0.0.0', port=10000, debug=False)