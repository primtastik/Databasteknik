from flask import Flask, render_template, request, redirect, url_for, session
import mysql.connector

app = Flask(__name__)

app.secret_key = 'our_secret_key'

# Database connection function
def get_db_connection():
    conn = mysql.connector.connect(
        host="localhost",
        user="dbadm",
        password="password",
        database="tester",
    )
    return conn

# Home Page Route
@app.route('/')
def home():

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # Fetch categories using the stored procedure
    cursor.callproc('fetch_categories')
    for result in cursor.stored_results():
        categories = result.fetchall()

    # Get the search query and selected category from the URL parameters
    search_query = request.args.get('search', '')
    category_id = request.args.get('category_id', None)

    # Build product query based on search and/or category
    if search_query and category_id:
        cursor.execute(
            "SELECT * FROM Products WHERE pName LIKE %s AND category_id = %s",
            (f"%{search_query}%", category_id)
        )
    elif search_query:
        cursor.execute(
            "SELECT * FROM Products WHERE pName LIKE %s",
            (f"%{search_query}%",)
        )
    elif category_id:
        cursor.execute(
            "SELECT * FROM Products WHERE category_id = %s",
            (category_id,)
        )
    else:
        cursor.execute("SELECT * FROM Products")
    
    products = cursor.fetchall()

    # Count number of items in the cart
    customer_id = session.get('customer_id', 100)
    cursor.execute("SELECT SUM(quantity) AS total_items FROM Cart_items WHERE customer_id = %s", (customer_id,))
    cart_item_count = cursor.fetchone()['total_items'] or 0

    cursor.close()
    conn.close()

    return render_template('home.html', categories=categories, products=products, cart_item_count=cart_item_count, search_query=search_query)

# Route to Add Product to Cart
@app.route('/add_to_cart/<int:product_id>')
def add_to_cart(product_id):
    customer_id = session.get('customer_id', 100)

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # Check if the cart exists for the customer
    cursor.execute("SELECT * FROM Cart WHERE customer_id = %s", (customer_id,))
    cart = cursor.fetchone()

    if not cart:
        # Create a cart if none exists
        cursor.execute("INSERT INTO Cart (customer_id) VALUES (%s)", (customer_id,))
        conn.commit()
        cursor.execute("SELECT * FROM Cart WHERE customer_id = %s", (customer_id,))
        cart = cursor.fetchone()

    # Add product to cart
    cursor.execute("INSERT INTO Cart_items (cart_id, customer_id, products_id, quantity) VALUES (%s, %s, %s, 1)",
                (cart['cart_id'], customer_id, product_id))
    conn.commit()

    cursor.close()
    conn.close()
    return redirect(url_for('home'))

# Route to Remove Product from Cart
@app.route('/cart')
def view_cart():
    customer_id = session.get('customer_id', 100)  # Default to 100
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    # Check if cart exists
    cursor.execute("SELECT * FROM Cart WHERE customer_id = %s", (customer_id,))
    cart = cursor.fetchone()

    if cart:
        # Fetch cart items
        cursor.execute('''
            SELECT ci.products_id, ci.quantity, p.pName AS name, p.price 
            FROM Cart_items ci
            JOIN Products p ON ci.products_id = p.products_id
            WHERE ci.cart_id = %s
        ''', (cart['cart_id'],))
        items = cursor.fetchall()

        # Calculate total cost
        cursor.execute('''
            SELECT SUM(ci.quantity * p.price) AS total_cost
            FROM Cart_items ci
            JOIN Products p ON ci.products_id = p.products_id
            WHERE ci.cart_id = %s
        ''', (cart['cart_id'],))
        total_cost = cursor.fetchone()['total_cost'] or 0  # Default to 0 if no items
    else:
        items = []
        total_cost = 0

    cursor.close()
    conn.close()
    return render_template('cart.html', items=items, total_cost=total_cost)

# Route to Remove Product from Cart
@app.route('/payment', methods=['GET', 'POST'])
def payment():
    customer_id = session.get('customer_id', 100)  # Default to 100
    if request.method == 'POST':
        payment_method = request.form['payment_method']

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Fetch the cart
        cursor.execute("SELECT * FROM Cart WHERE customer_id = %s", (customer_id,))
        cart = cursor.fetchone()

        if not cart:
            return "Error: No cart found.", 400
        
        cart_id = cart['cart_id'] #NEW

        # Calculate total order amount
        cursor.execute('''
            SELECT SUM(ci.quantity * p.price) AS total_cost
            FROM Cart_items ci
            JOIN Products p ON ci.products_id = p.products_id
            WHERE ci.cart_id = %s
        ''', (cart['cart_id'],))
        total_cost = cursor.fetchone()['total_cost'] or 0
        
        # Create order
        cursor.execute('''
            INSERT INTO Orders (customer_id, order_sum)
            VALUES (%s, %s)
        ''', (customer_id, total_cost))
        order_id = cursor.lastrowid  # Get the generated order_id

        # Insert order items (THIS TRIGGERS STOCK UPDATE)
        cursor.execute('''
            SELECT products_id, quantity
            FROM Cart_items
            WHERE cart_id = %s
        ''', (cart_id,))
        cart_items = cursor.fetchall()

        for item in cart_items:
            cursor.execute('''
                INSERT INTO Order_items (orders_id, products_id, quantity)
                VALUES (%s, %s, %s)
            ''', (order_id, item['products_id'], item['quantity']))

        # Insert payment
        cursor.execute('''
            INSERT INTO Payment (orders_id, payment_method, payment_status)
            VALUES (%s, %s, %s)
        ''', (order_id, payment_method, 'Pending'))

        # Clear cart
        cursor.execute("DELETE FROM Cart_items WHERE cart_id = %s", (cart_id,))
        conn.commit()

        cursor.close()
        conn.close()

        # Redirect to the payment success page
        return redirect(url_for('payment_success', order_id=order_id))

    return render_template('payment.html')

# Route to handle payment success
@app.route('/payment_success/<int:order_id>')
def payment_success(order_id):
    return render_template('payment_success.html', order_id=order_id)


if __name__ == '__main__':
    app.run(debug=True)
