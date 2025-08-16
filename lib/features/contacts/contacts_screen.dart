import 'package:flutter/material.dart';

/// ======= MODELO =======
enum ContactType { caregiver, doctor, family }

class Contact {
  final String id;
  final String name;
  final ContactType type;
  final String subtitle; // cargo/relacao: "Cuidador(a)", "Cardiologista", "Filho(a)"
  final String phone;
  final String? email;

  Contact({
    required this.id,
    required this.name,
    required this.type,
    required this.subtitle,
    required this.phone,
    this.email,
  });
}

/// ======= MOCK por paciente =======
List<Contact> mockContacts(String patientId) {
  final k = patientId.length;
  return [
    Contact(
      id: 'c1',
      name: 'Mariana Dias',
      type: ContactType.caregiver,
      subtitle: 'Cuidadora (diurno)',
      phone: '(51) 9${7000 + k}‑1122',
      email: 'mariana@cuidadores.com',
    ),
    Contact(
      id: 'c2',
      name: 'Pedro Alves',
      type: ContactType.caregiver,
      subtitle: 'Cuidador (noturno)',
      phone: '(51) 9${7100 + k}‑3344',
      email: 'pedro@cuidadores.com',
    ),
    Contact(
      id: 'c3',
      name: 'Dra. Camila Rocha',
      type: ContactType.doctor,
      subtitle: 'Clínica Geral',
      phone: '(51) 9${7200 + k}‑5566',
      email: 'camila.rocha@clinica.com',
    ),
    Contact(
      id: 'c4',
      name: 'Dr. João Henrique',
      type: ContactType.doctor,
      subtitle: 'Cardiologista',
      phone: '(51) 9${7300 + k}‑7788',
      email: 'joao.henrique@hospital.com',
    ),
    Contact(
      id: 'c5',
      name: 'Ana Paula',
      type: ContactType.family,
      subtitle: 'Filha',
      phone: '(51) 9${7400 + k}‑9900',
      email: 'ana.paula@email.com',
    ),
    Contact(
      id: 'c6',
      name: 'Carlos Nonato',
      type: ContactType.family,
      subtitle: 'Irmão',
      phone: '(51) 9${7500 + k}‑2211',
    ),
  ];
}

/// ======= TELA =======
class ContactsScreen extends StatefulWidget {
  final String patientId;
  final String? patientName;

  const ContactsScreen({
    super.key,
    required this.patientId,
    this.patientName,
  });

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late List<Contact> _all;
  String _query = '';
  final Set<ContactType> _filters = {ContactType.caregiver, ContactType.doctor, ContactType.family};

  @override
  void initState() {
    super.initState();
    _all = mockContacts(widget.patientId);
  }

  List<Contact> get _visible {
    final q = _query.trim().toLowerCase();
    return _all.where((c) {
      final matchesType = _filters.contains(c.type);
      final matchesQuery = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.subtitle.toLowerCase().contains(q);
      return matchesType && matchesQuery;
    }).toList();
  }

  void _toggle(ContactType t) {
    setState(() {
      if (_filters.contains(t)) {
        _filters.remove(t);
      } else {
        _filters.add(t);
      }
    });
  }

  void _fakeCall(Contact c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ligando para ${c.name} — ${c.phone} (mock)')),
    );
  }

  void _fakeMsg(Contact c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrindo mensagem para ${c.name} (mock)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName == null
            ? 'Contatos'
            : 'Contatos — ${widget.patientName}'),
        backgroundColor: cs.primary.withOpacity(0.08),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou função…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.primary.withOpacity(0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
            ),
          ),
          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Cuidadores',
                  selected: _filters.contains(ContactType.caregiver),
                  icon: Icons.volunteer_activism_outlined,
                  onTap: () => _toggle(ContactType.caregiver),
                ),
                _FilterChip(
                  label: 'Médicos',
                  selected: _filters.contains(ContactType.doctor),
                  icon: Icons.local_hospital_outlined,
                  onTap: () => _toggle(ContactType.doctor),
                ),
                _FilterChip(
                  label: 'Familiares',
                  selected: _filters.contains(ContactType.family),
                  icon: Icons.family_restroom_outlined,
                  onTap: () => _toggle(ContactType.family),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Lista
          Expanded(
            child: _visible.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final c = _visible[index];
                      return _ContactCard(
                        contact: c,
                        onCall: () => _fakeCall(c),
                        onMessage: () => _fakeMsg(c),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// ======= WIDGETS =======

class _ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const _ContactCard({
    required this.contact,
    required this.onCall,
    required this.onMessage,
  });

  IconData get _typeIcon {
    switch (contact.type) {
      case ContactType.caregiver:
        return Icons.volunteer_activism_outlined;
      case ContactType.doctor:
        return Icons.local_hospital_outlined;
      case ContactType.family:
        return Icons.family_restroom_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, cs.primary.withOpacity(0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            _AvatarFromName(name: contact.name, icon: _typeIcon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          contact.phone,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (contact.email != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.mail_outline, size: 16, color: Colors.black54),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            contact.email!,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              children: [
                IconButton(
                  tooltip: 'Ligar',
                  onPressed: onCall,
                  icon: const Icon(Icons.call),
                  color: cs.primary,
                ),
                IconButton(
                  tooltip: 'Mensagem',
                  onPressed: onMessage,
                  icon: const Icon(Icons.sms_outlined),
                  color: cs.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarFromName extends StatelessWidget {
  final String name;
  final IconData icon;
  const _AvatarFromName({required this.name, required this.icon});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 22,
      backgroundColor: cs.primary.withOpacity(0.18),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            _initials,
            style: TextStyle(
              color: cs.primary.withOpacity(0.9),
              fontWeight: FontWeight.bold,
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: Icon(icon, size: 14, color: cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.contacts_outlined, color: cs.primary, size: 48),
            const SizedBox(height: 10),
            Text(
              'Nenhum contato encontrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ajuste os filtros ou sua busca.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? cs.primary.withOpacity(0.18) : cs.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? cs.primary.withOpacity(0.6) : Colors.black12,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: cs.primary.withOpacity(0.95),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
