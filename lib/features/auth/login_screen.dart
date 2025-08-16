import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController(text: 'candice70@example.com');
  final passwordCtrl = TextEditingController(text: '********3');
  bool obscure = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  void onSignIn() {
    if (formKey.currentState?.validate() ?? false) {
      // Aqui você chamaria sua API. Por enquanto: navega para a lista.
      Navigator.of(context).pushReplacementNamed('/patients');
    }
  }

  void onRegisterTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ir para cadastro')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: _LanguagePill(
        label: 'BR',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Idioma: Português (Brasil)')),
          );
        },
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.eco_rounded, size: 52, color: cs.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bem-vindo ao Bayleaf',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Material(
                    elevation: 3,
                    shadowColor: Colors.black12,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6, bottom: 6),
                                child: Text('E-mail',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black54),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'candice70@example.com',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Informe seu e-mail';
                                final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
                                return ok ? null : 'E-mail inválido';
                              },
                            ),
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6, bottom: 6),
                                child: Text('Senha',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black54),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: passwordCtrl,
                              obscureText: obscure,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: obscure ? 'Mostrar senha' : 'Ocultar senha',
                                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => obscure = !obscure),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Informe sua senha';
                                if (v.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: onSignIn,
                                child: const Text('Entrar'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextButton(
                    onPressed: onRegisterTap,
                    child: const Text(
                      'Não tem uma conta? Cadastre-se aqui',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LanguagePill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 56, height: 56, alignment: Alignment.center,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
