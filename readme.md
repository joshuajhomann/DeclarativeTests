# Declarative Tests

This project shows the use of `@resultBuilder` to make a declarative testing framework.

```
expect {
        When {
            viewModel.input = 1
            viewModel.input = 2
            viewModel.input = 3
        }
        That {
            Output(of: viewModel.$doubled).contains(6)
            Output(of: viewModel.$doubled).at(1, equals: 2)
            Output(of: viewModel.$doubled).in(1...3, equals: [2,4,6])
            Output(of: viewModel.$tripled).prefixEquals([0,3,6,9])
        }
    }
}
```
