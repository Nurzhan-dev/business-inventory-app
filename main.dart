import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html;

void main() {
  runApp(const MyApp());
}

// Корневой виджет приложения
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Бизнес-инвентаризация',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: const HomeScreen(),
    );
  }
}

// Модель данных для товара
class Product {
  final String id;
  String name;
  String? imageUrl; // Теперь это URL изображения
  double purchasePrice;
  double sellingPrice;
  int stockCount;
  String? description;

  Product({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stockCount,
    this.description,
  });
}

// Модель данных для транзакции
class Transaction {
  final String id;
  final String productId;
  final int quantity;
  final double amount;
  final DateTime date;

  Transaction({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.amount,
    required this.date,
  });
}

// Новая модель данных для расходов
class Expense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });
}

// Временное хранилище для всех товаров, транзакций и расходов
final List<Product> _products = [
  Product(
    id: const Uuid().v4(),
    name: 'Кофейные зёрна Ethiopia',
    imageUrl: 'https://cdn.pixabay.com/photo/2017/02/09/16/06/coffee-beans-2053159_1280.jpg',
    purchasePrice: 4000.0,
    sellingPrice: 5500.0,
    stockCount: 100,
    description: 'Арабика из Эфиопии, выращенная в высокогорье.',
  ),
  Product(
    id: const Uuid().v4(),
    name: 'Кофеварка рожковая',
    imageUrl: 'https://cdn.pixabay.com/photo/2016/10/24/22/07/coffee-machine-1767119_1280.jpg',
    purchasePrice: 50000.0,
    sellingPrice: 75000.0,
    stockCount: 15,
  ),
];

final List<Transaction> _transactions = [];
final List<Expense> _expenses = [];

// Главный экран приложения
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главный экран'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Приветственное сообщение
            const Text(
              'Добро пожаловать в систему инвентаризации!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Управляйте своими товарами и запасами эффективно.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            // Кнопка для перехода к экрану учёта товаров
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductManagementScreen()),
                );
              },
              icon: const Icon(Icons.inventory_2),
              label: const Text('Учёт товаров'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Кнопка для перехода к отчётам
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportsScreen()),
                );
              },
              icon: const Icon(Icons.assessment),
              label: const Text('Отчёты'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Кнопка для перехода к экрану продаж
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SalesScreen()),
                );
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Зарегистрировать продажу'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Кнопка для перехода к экрану расходов
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpenseScreen()),
                );
              },
              icon: const Icon(Icons.money_off),
              label: const Text('Учёт расходов'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Страница для управления товарами (список и добавление)
class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Учёт товаров'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: SizedBox(
                width: 50,
                height: 50,
                child: product.imageUrl != null
                    ? Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 30),)
                    : const Icon(Icons.inventory_2, size: 30),
              ),
              title: Text(product.name),
              subtitle: Text('Количество: ${product.stockCount}\nЦена: ${product.sellingPrice} тг'),
              onTap: () async {
                final updatedProduct = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(
                      product: product,
                    ),
                  ),
                );
                if (updatedProduct != null) {
                  setState(() {
                    final updatedIndex = _products.indexWhere((p) => p.id == updatedProduct.id);
                    if (updatedIndex != -1) {
                      _products[updatedIndex] = updatedProduct;
                    }
                  });
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newProduct = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductDetailPage(),
            ),
          );
          if (newProduct != null) {
            setState(() {
              _products.add(newProduct);
            });
          }
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Страница для отображения и редактирования товара
class ProductDetailPage extends StatefulWidget {
  final Product? product;
  const ProductDetailPage({
    super.key,
    this.product,
  });

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product _currentProduct;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product ??
        Product(
          id: const Uuid().v4(),
          name: '',
          purchasePrice: 0.0,
          sellingPrice: 0.0,
          stockCount: 0,
        );
  }

  // Функция для "выбора" изображения
  void _pickImage() {
    setState(() {
      _currentProduct.imageUrl = 'https://picsum.photos/400/300';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Новый товар' : 'Редактировать товар'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Название товара',
                initialValue: _currentProduct.name,
                onSaved: (value) => _currentProduct.name = value!,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Цена покупки (тг)',
                initialValue: _currentProduct.purchasePrice.toString(),
                keyboardType: TextInputType.number,
                onSaved: (value) => _currentProduct.purchasePrice = double.tryParse(value!) ?? 0.0,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Цена продажи (тг)',
                initialValue: _currentProduct.sellingPrice.toString(),
                keyboardType: TextInputType.number,
                onSaved: (value) => _currentProduct.sellingPrice = double.tryParse(value!) ?? 0.0,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Количество на складе',
                initialValue: _currentProduct.stockCount.toString(),
                keyboardType: TextInputType.number,
                onSaved: (value) => _currentProduct.stockCount = int.tryParse(value!) ?? 0,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Описание',
                initialValue: _currentProduct.description,
                maxLines: 3,
                onSaved: (value) => _currentProduct.description = value,
                validator: null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveProduct,
                icon: const Icon(Icons.save),
                label: const Text('Сохранить товар'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[400]!),
          image: _currentProduct.imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(_currentProduct.imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _currentProduct.imageUrl == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_a_photo,
                      size: 50,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Нажмите, чтобы загрузить фото',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    required void Function(String?) onSaved,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Это поле не может быть пустым';
        }
        return null;
      },
      onSaved: onSaved,
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, _currentProduct);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Товар успешно сохранён!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

// Страница для отчётов
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Функция для генерации и скачивания CSV-файла
  void _generateCsvAndDownload() {
    final List<List<dynamic>> csvData = [
      ['Дата', 'Тип', 'Описание', 'Сумма (тг)'],
    ];

    // Добавляем данные о транзакциях
    for (var transaction in _transactions) {
      final product = _products.firstWhere((p) => p.id == transaction.productId);
      final profit = (product.sellingPrice - product.purchasePrice) * transaction.quantity;
      csvData.add([
        transaction.date.toIso8601String().substring(0, 10),
        'Продажа',
        'Продажа ${product.name}',
        profit.toStringAsFixed(2),
      ]);
    }

    // Добавляем данные о расходах
    for (var expense in _expenses) {
      csvData.add([
        expense.date.toIso8601String().substring(0, 10),
        'Расход',
        expense.description,
        (-expense.amount).toStringAsFixed(2),
      ]);
    }

    final String csv = const ListToCsvConverter().convert(csvData);
    final blob = html.Blob([csv], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'business_report.csv');
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }
  
  @override
  Widget build(BuildContext context) {
    // Рассчитываем общую прибыль от продаж
    double totalProfit = 0.0;
    for (var transaction in _transactions) {
      final product = _products.firstWhere((p) => p.id == transaction.productId);
      totalProfit += (product.sellingPrice - product.purchasePrice) * transaction.quantity;
    }

    // Рассчитываем общую сумму расходов
    double totalExpenses = 0.0;
    for (var expense in _expenses) {
      totalExpenses += expense.amount;
    }

    final netProfit = totalProfit - totalExpenses;

    // Находим самые продаваемые товары
    final Map<String, int> salesCount = {};
    for (var transaction in _transactions) {
      salesCount[transaction.productId] = (salesCount[transaction.productId] ?? 0) + transaction.quantity;
    }

    final sortedProducts = salesCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Форматируем список самых продаваемых товаров
    List<Widget> bestSellingList = [];
    if (sortedProducts.isEmpty) {
      bestSellingList.add(const Text('Нет данных о продажах.'));
    } else {
      for (var entry in sortedProducts) {
        final product = _products.firstWhere((p) => p.id == entry.key);
        bestSellingList.add(
          ListTile(
            title: Text(product.name),
            trailing: Text('${entry.value} шт.'),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчёты'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Чистая прибыль',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${netProfit.toStringAsFixed(2)} тг',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: netProfit >= 0 ? Colors.green : Colors.red),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Продажи: ${totalProfit.toStringAsFixed(2)} тг', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        Text('Расходы: ${totalExpenses.toStringAsFixed(2)} тг', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Самые продаваемые товары:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: bestSellingList,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateCsvAndDownload,
              icon: const Icon(Icons.download),
              label: const Text('Экспортировать отчёт'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Страница для регистрации продажи
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Product? _selectedProduct;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Зарегистрировать продажу'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Выберите товар:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Выпадающий список товаров
            DropdownButtonFormField<Product>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: 'Товар',
              ),
              value: _selectedProduct,
              items: _products.map((product) {
                return DropdownMenuItem<Product>(
                  value: product,
                  child: Text('${product.name} (${product.stockCount} шт.)'),
                );
              }).toList(),
              onChanged: (Product? newValue) {
                setState(() {
                  _selectedProduct = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_selectedProduct != null)
              _buildQuantitySection(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _selectedProduct != null ? _registerSale : null,
              icon: const Icon(Icons.check),
              label: const Text('Зарегистрировать'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Количество:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (_quantity > 1) {
                  setState(() {
                    _quantity--;
                  });
                }
              },
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: Text(
                _quantity.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            IconButton(
              onPressed: () {
                if (_selectedProduct!.stockCount > _quantity) {
                  setState(() {
                    _quantity++;
                  });
                }
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  void _registerSale() {
    if (_selectedProduct == null || _quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, выберите товар и количество.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_selectedProduct!.stockCount < _quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('На складе недостаточно товара.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final saleAmount = _selectedProduct!.sellingPrice * _quantity;
    final newTransaction = Transaction(
      id: const Uuid().v4(),
      productId: _selectedProduct!.id,
      quantity: _quantity,
      amount: saleAmount,
      date: DateTime.now(),
    );

    _transactions.add(newTransaction);
    _selectedProduct!.stockCount -= _quantity;

    // Обновляем состояние, чтобы UI перерисовался
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Продажа зарегистрирована! Сумма: ${saleAmount.toStringAsFixed(2)} тг'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Страница для учёта расходов
class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Учёт расходов'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          final expense = _expenses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.money_off, color: Colors.red),
              title: Text(expense.description),
              subtitle: Text(
                '${expense.amount.toStringAsFixed(2)} тг',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newExpense = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
          if (newExpense != null) {
            setState(() {
              _expenses.add(newExpense);
            });
          }
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Страница для добавления нового расхода
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final newExpense = Expense(
        id: const Uuid().v4(),
        description: _descriptionController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        date: DateTime.now(),
      );
      Navigator.pop(context, newExpense);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Расход успешно добавлен!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить расход'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Описание расхода',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите описание';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Сумма (тг)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите сумму';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Введите корректное число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveExpense,
                icon: const Icon(Icons.add_circle),
                label: const Text('Добавить расход'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
