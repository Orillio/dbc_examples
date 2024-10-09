import '../lib/contract.dart';

class Account extends Contract {
  Account(this.id);

  int _balance = 100;

  int get balance => _balance;

  final int id;

  @override
  Map<String, bool> get invariantAsserts => {
        'balance must be positive': balance >= 0,
      };

  void withdraw(int sum) {
    final oldBalance = balance;
    require({
      'sum must be positive and less than current balance':
          sum > 0 && sum <= balance,
    });

    _balance -= sum;

    ensure({
      'sum should be withdrawn from balance': balance + sum == oldBalance,
    });
  }

  void transferTo(Account payee, int sum) {
    final oldBalance = balance;
    require({
      'sum must be positive and less than current balance':
          sum > 0 && sum <= balance,
      'can not transfer to self': id != payee.id,
    });

    _balance -= sum;
    payee.receiveFrom(this, sum);

    ensure({
      'sum should be withdrawn from balance': balance + sum == oldBalance,
    });
  }

  void receiveFrom(Account payer, int sum) {
    final oldBalance = balance;
    require({
      'sum must be positive': sum > 0,
      'can not bet received from self': id != payer.id,
    });

    _balance += sum;

    ensure({
      'balance should increase': balance - oldBalance == sum,
    });
  }

  void deposit(int sum) {
    final oldBalance = balance;
    require({
      'sum must be > 0': sum > 0,
    });

    _balance += sum;
    ensure({
      'balance should increase': balance - oldBalance == sum,
    });
  }
}

void main(List<String> arguments) {
  final a = Account(1);
  final b = Account(2);

  print(a.balance); // 100
  a.deposit(100);
  print(a.balance); // 200
  a.transferTo(b, 30);
  print(a.balance); // 170
  print(b.balance); // 130

  a.withdraw(50);
  print(a.balance); // 120
  a.withdraw(120); 
  print(a.balance); // 0 
  a.withdraw(10); // Assertion Error
}
