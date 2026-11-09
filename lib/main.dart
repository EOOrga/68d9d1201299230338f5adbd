import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

const String appName = 'CHAUVE MICHEL';
const String supportEmail = 'support@chauvemichel.com';
const bool kScreenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

const Color brandNavy = Color(0xFF001330);
const Color brandInk = Color(0xFF071E34);
const Color brandTeal = Color(0xFF0582A6);
const Color brandCyan = Color(0xFF0ABBD3);
const Color brandGold = Color(0xFFC99222);
const Color brandGreen = Color(0xFF1F8F5F);
const Color brandRed = Color(0xFFC94B4B);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChauveMichelApp());
}

class ChauveMichelApp extends StatelessWidget {
  const ChauveMichelApp({super.key, this.screenshotMode = kScreenshotMode});

  final bool screenshotMode;

  @override
  Widget build(BuildContext context) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: brandTeal,
          brightness: Brightness.light,
        ).copyWith(
          primary: brandNavy,
          onPrimary: Colors.white,
          secondary: brandTeal,
          tertiary: brandGold,
          surface: const Color(0xFFF8FAFC),
          surfaceContainerHighest: const Color(0xFFE8F1F4),
        );

    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F8FA),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFFF4F8FA),
          foregroundColor: brandNavy,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: brandNavy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFD9E6EA)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: brandTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: brandTeal.withValues(alpha: 0.16),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
        ),
      ),
      home: OperationsShell(screenshotMode: screenshotMode),
    );
  }
}

class OperationsShell extends StatefulWidget {
  const OperationsShell({super.key, required this.screenshotMode});

  final bool screenshotMode;

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  late final OperationsRepository repository;
  var selectedIndex = 0;
  var loading = true;

  @override
  void initState() {
    super.initState();
    repository = OperationsRepository(screenshotMode: widget.screenshotMode);
    _load();
  }

  Future<void> _load() async {
    await repository.load();
    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(repository: repository),
      AssetsPage(
        repository: repository,
        onAdd: _showAssetForm,
        onChanged: _refresh,
      ),
      QualityPage(
        repository: repository,
        onAdd: _showInspectionForm,
        onChanged: _refresh,
      ),
      ShiftsPage(
        repository: repository,
        onAdd: _showShiftForm,
        onChanged: _refresh,
      ),
      CompliancePage(
        repository: repository,
        onAdd: _showComplianceForm,
        onChanged: _refresh,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(appName),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      SettingsPage(repository: repository, onChanged: _refresh),
                ),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(child: pages[selectedIndex]),
      floatingActionButton: _floatingActionButton(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Assets',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Quality',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Shifts',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(Icons.verified_user),
            label: 'Compliance',
          ),
        ],
      ),
    );
  }

  Widget? _floatingActionButton() {
    final actions = <VoidCallback?>[
      null,
      _showAssetForm,
      _showInspectionForm,
      _showShiftForm,
      _showComplianceForm,
    ];
    final action = actions[selectedIndex];
    if (action == null) {
      return null;
    }
    return FloatingActionButton(
      tooltip: 'Add record',
      onPressed: action,
      child: const Icon(Icons.add),
    );
  }

  Future<void> _showAssetForm() async {
    final record = await showModalBottomSheet<AssetRecord>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AssetFormSheet(),
    );
    if (record != null) {
      await repository.addAsset(record);
      _refresh();
    }
  }

  Future<void> _showInspectionForm() async {
    final record = await showModalBottomSheet<InspectionRecord>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const InspectionFormSheet(),
    );
    if (record != null) {
      await repository.addInspection(record);
      _refresh();
    }
  }

  Future<void> _showShiftForm() async {
    final record = await showModalBottomSheet<ShiftRecord>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ShiftFormSheet(),
    );
    if (record != null) {
      await repository.addShift(record);
      _refresh();
    }
  }

  Future<void> _showComplianceForm() async {
    final record = await showModalBottomSheet<ComplianceRecord>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ComplianceFormSheet(),
    );
    if (record != null) {
      await repository.addCompliance(record);
      _refresh();
    }
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}

class OperationsRepository {
  OperationsRepository({required this.screenshotMode});

  final bool screenshotMode;
  Map<String, dynamic> _storage = {};
  List<AssetRecord> assets = [];
  List<InspectionRecord> inspections = [];
  List<ShiftRecord> shifts = [];
  List<ComplianceRecord> complianceReports = [];
  WorkspaceSettings settings = WorkspaceSettings.sample();

  File get _storageFile =>
      File('${Directory.systemTemp.path}/chauve_michel_records.json');

  Future<void> load() async {
    if (screenshotMode) {
      _loadSampleData();
      return;
    }

    final file = _storageFile;
    if (await file.exists()) {
      try {
        _storage = Map<String, dynamic>.from(
          jsonDecode(await file.readAsString()),
        );
      } on FormatException {
        _storage = {};
      }
    }
    assets = _readList('assets', AssetRecord.fromJson);
    inspections = _readList('inspections', InspectionRecord.fromJson);
    shifts = _readList('shifts', ShiftRecord.fromJson);
    complianceReports = _readList('compliance', ComplianceRecord.fromJson);
    settings = WorkspaceSettings.fromJson(
      _readMap('settings') ?? WorkspaceSettings.sample().toJson(),
    );

    if (assets.isEmpty &&
        inspections.isEmpty &&
        shifts.isEmpty &&
        complianceReports.isEmpty) {
      _loadSampleData();
      await _saveAll();
    }
  }

  int get openIssues =>
      inspections.where((item) => !item.completed).length +
      complianceReports.where((item) => item.status != 'Filed').length +
      assets.where((item) => item.condition == 'Needs service').length;

  int get readyAssets =>
      assets.where((item) => item.condition == 'Ready').length;

  int get todayShifts => shifts.where((item) => item.status != 'Closed').length;

  int get qualityScore {
    if (inspections.isEmpty) {
      return 0;
    }
    final total = inspections.fold<int>(0, (sum, item) => sum + item.score);
    return (total / inspections.length).round();
  }

  Future<void> addAsset(AssetRecord record) async {
    assets = [record.withId(_id('asset')), ...assets];
    await _save('assets', assets.map((item) => item.toJson()).toList());
  }

  Future<void> addInspection(InspectionRecord record) async {
    inspections = [record.withId(_id('inspection')), ...inspections];
    await _save(
      'inspections',
      inspections.map((item) => item.toJson()).toList(),
    );
  }

  Future<void> addShift(ShiftRecord record) async {
    shifts = [record.withId(_id('shift')), ...shifts];
    await _save('shifts', shifts.map((item) => item.toJson()).toList());
  }

  Future<void> addCompliance(ComplianceRecord record) async {
    complianceReports = [
      record.withId(_id('compliance')),
      ...complianceReports,
    ];
    await _save(
      'compliance',
      complianceReports.map((item) => item.toJson()).toList(),
    );
  }

  Future<void> toggleInspection(String id, bool completed) async {
    inspections = inspections
        .map(
          (item) => item.id == id ? item.copyWith(completed: completed) : item,
        )
        .toList();
    await _save(
      'inspections',
      inspections.map((item) => item.toJson()).toList(),
    );
  }

  Future<void> updateSettings(WorkspaceSettings next) async {
    settings = next;
    await _saveMap('settings', next.toJson());
  }

  void _loadSampleData() {
    assets = [
      const AssetRecord(
        id: 'asset-001',
        name: 'Forklift A12',
        tag: 'FLT-A12',
        zone: 'Receiving dock',
        owner: 'Karim',
        condition: 'Ready',
        nextService: 'May 14',
        note: 'Battery check completed before morning loading window.',
      ),
      const AssetRecord(
        id: 'asset-002',
        name: 'Cold room sensor',
        tag: 'QA-CR-07',
        zone: 'Storage lane 3',
        owner: 'Imane',
        condition: 'Needs service',
        nextService: 'Today',
        note: 'Calibration drift flagged during quality pass.',
      ),
      const AssetRecord(
        id: 'asset-003',
        name: 'Packing line scale',
        tag: 'PKG-SC-21',
        zone: 'Packaging',
        owner: 'Samir',
        condition: 'Ready',
        nextService: 'May 18',
        note: 'Seal intact and weight tolerance within limit.',
      ),
    ];
    inspections = [
      const InspectionRecord(
        id: 'inspection-001',
        area: 'Inbound pallets',
        checklist: 'Seal, count, label, damage',
        completed: true,
        score: 96,
        date: 'Today 08:20',
        issue: 'No blocking issue',
      ),
      const InspectionRecord(
        id: 'inspection-002',
        area: 'Cold storage',
        checklist: 'Temperature, logs, door gasket',
        completed: false,
        score: 82,
        date: 'Today 10:15',
        issue: 'Sensor QA-CR-07 requires calibration',
      ),
      const InspectionRecord(
        id: 'inspection-003',
        area: 'Dispatch staging',
        checklist: 'Load plan, straps, paperwork',
        completed: true,
        score: 91,
        date: 'Yesterday 17:40',
        issue: 'Two labels reprinted',
      ),
    ];
    shifts = [
      const ShiftRecord(
        id: 'shift-001',
        role: 'Receiving lead',
        lead: 'Karim A.',
        window: '06:00 - 14:00',
        coverage: '4 operators',
        status: 'Active',
      ),
      const ShiftRecord(
        id: 'shift-002',
        role: 'Quality control',
        lead: 'Imane B.',
        window: '08:00 - 16:00',
        coverage: '2 inspectors',
        status: 'Active',
      ),
      const ShiftRecord(
        id: 'shift-003',
        role: 'Dispatch close',
        lead: 'Youssef C.',
        window: '16:00 - 23:00',
        coverage: '3 operators',
        status: 'Planned',
      ),
    ];
    complianceReports = [
      const ComplianceRecord(
        id: 'compliance-001',
        title: 'CHAUVE MICHEL',
        owner: 'Operations',
        dueDate: 'May 12',
        status: 'Filed',
        evidence: 'Signed checklist and incident log attached locally.',
      ),
      const ComplianceRecord(
        id: 'compliance-002',
        title: 'Calibration exception',
        owner: 'Quality',
        dueDate: 'Today',
        status: 'Review',
        evidence: 'Cold room sensor drift noted for maintenance follow-up.',
      ),
      const ComplianceRecord(
        id: 'compliance-003',
        title: 'Shift coverage report',
        owner: 'Planning',
        dueDate: 'May 13',
        status: 'Draft',
        evidence: 'Coverage notes prepared for evening handoff.',
      ),
    ];
    settings = WorkspaceSettings.sample();
  }

  List<T> _readList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final decoded = _storage[key];
    if (decoded is! List) {
      return [];
    }
    return decoded
        .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Map<String, dynamic>? _readMap(String key) {
    final decoded = _storage[key];
    if (decoded is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> _save(String key, Object value) async {
    if (screenshotMode) {
      return;
    }
    _storage[key] = value;
    await _writeStorage();
  }

  Future<void> _saveMap(String key, Map<String, dynamic> value) async {
    await _save(key, value);
  }

  Future<void> _saveAll() async {
    await _save('assets', assets.map((item) => item.toJson()).toList());
    await _save(
      'inspections',
      inspections.map((item) => item.toJson()).toList(),
    );
    await _save('shifts', shifts.map((item) => item.toJson()).toList());
    await _save(
      'compliance',
      complianceReports.map((item) => item.toJson()).toList(),
    );
    await _saveMap('settings', settings.toJson());
  }

  Future<void> _writeStorage() async {
    final file = _storageFile;
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(_storage));
  }

  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}';
}

class AssetRecord {
  const AssetRecord({
    required this.id,
    required this.name,
    required this.tag,
    required this.zone,
    required this.owner,
    required this.condition,
    required this.nextService,
    required this.note,
  });

  final String id;
  final String name;
  final String tag;
  final String zone;
  final String owner;
  final String condition;
  final String nextService;
  final String note;

  AssetRecord withId(String nextId) => AssetRecord(
    id: nextId,
    name: name,
    tag: tag,
    zone: zone,
    owner: owner,
    condition: condition,
    nextService: nextService,
    note: note,
  );

  factory AssetRecord.fromJson(Map<String, dynamic> json) => AssetRecord(
    id: json['id'] as String,
    name: json['name'] as String,
    tag: json['tag'] as String,
    zone: json['zone'] as String,
    owner: json['owner'] as String,
    condition: json['condition'] as String,
    nextService: json['nextService'] as String,
    note: json['note'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tag': tag,
    'zone': zone,
    'owner': owner,
    'condition': condition,
    'nextService': nextService,
    'note': note,
  };
}

class InspectionRecord {
  const InspectionRecord({
    required this.id,
    required this.area,
    required this.checklist,
    required this.completed,
    required this.score,
    required this.date,
    required this.issue,
  });

  final String id;
  final String area;
  final String checklist;
  final bool completed;
  final int score;
  final String date;
  final String issue;

  InspectionRecord withId(String nextId) => InspectionRecord(
    id: nextId,
    area: area,
    checklist: checklist,
    completed: completed,
    score: score,
    date: date,
    issue: issue,
  );

  InspectionRecord copyWith({bool? completed}) => InspectionRecord(
    id: id,
    area: area,
    checklist: checklist,
    completed: completed ?? this.completed,
    score: score,
    date: date,
    issue: issue,
  );

  factory InspectionRecord.fromJson(Map<String, dynamic> json) =>
      InspectionRecord(
        id: json['id'] as String,
        area: json['area'] as String,
        checklist: json['checklist'] as String,
        completed: json['completed'] as bool,
        score: json['score'] as int,
        date: json['date'] as String,
        issue: json['issue'] as String,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'area': area,
    'checklist': checklist,
    'completed': completed,
    'score': score,
    'date': date,
    'issue': issue,
  };
}

class ShiftRecord {
  const ShiftRecord({
    required this.id,
    required this.role,
    required this.lead,
    required this.window,
    required this.coverage,
    required this.status,
  });

  final String id;
  final String role;
  final String lead;
  final String window;
  final String coverage;
  final String status;

  ShiftRecord withId(String nextId) => ShiftRecord(
    id: nextId,
    role: role,
    lead: lead,
    window: window,
    coverage: coverage,
    status: status,
  );

  factory ShiftRecord.fromJson(Map<String, dynamic> json) => ShiftRecord(
    id: json['id'] as String,
    role: json['role'] as String,
    lead: json['lead'] as String,
    window: json['window'] as String,
    coverage: json['coverage'] as String,
    status: json['status'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'lead': lead,
    'window': window,
    'coverage': coverage,
    'status': status,
  };
}

class ComplianceRecord {
  const ComplianceRecord({
    required this.id,
    required this.title,
    required this.owner,
    required this.dueDate,
    required this.status,
    required this.evidence,
  });

  final String id;
  final String title;
  final String owner;
  final String dueDate;
  final String status;
  final String evidence;

  ComplianceRecord withId(String nextId) => ComplianceRecord(
    id: nextId,
    title: title,
    owner: owner,
    dueDate: dueDate,
    status: status,
    evidence: evidence,
  );

  factory ComplianceRecord.fromJson(Map<String, dynamic> json) =>
      ComplianceRecord(
        id: json['id'] as String,
        title: json['title'] as String,
        owner: json['owner'] as String,
        dueDate: json['dueDate'] as String,
        status: json['status'] as String,
        evidence: json['evidence'] as String,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'owner': owner,
    'dueDate': dueDate,
    'status': status,
    'evidence': evidence,
  };
}

class WorkspaceSettings {
  const WorkspaceSettings({
    required this.siteName,
    required this.managerName,
    required this.localLock,
    required this.weeklyDigest,
  });

  final String siteName;
  final String managerName;
  final bool localLock;
  final bool weeklyDigest;

  static WorkspaceSettings sample() => const WorkspaceSettings(
    siteName: 'Main operations site',
    managerName: 'CHAUVE MICHEL',
    localLock: true,
    weeklyDigest: false,
  );

  WorkspaceSettings copyWith({
    String? siteName,
    String? managerName,
    bool? localLock,
    bool? weeklyDigest,
  }) => WorkspaceSettings(
    siteName: siteName ?? this.siteName,
    managerName: managerName ?? this.managerName,
    localLock: localLock ?? this.localLock,
    weeklyDigest: weeklyDigest ?? this.weeklyDigest,
  );

  factory WorkspaceSettings.fromJson(Map<String, dynamic> json) =>
      WorkspaceSettings(
        siteName: json['siteName'] as String,
        managerName: json['managerName'] as String,
        localLock: json['localLock'] as bool,
        weeklyDigest: json['weeklyDigest'] as bool,
      );

  Map<String, dynamic> toJson() => {
    'siteName': siteName,
    'managerName': managerName,
    'localLock': localLock,
    'weeklyDigest': weeklyDigest,
  };
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.repository});

  final OperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: brandNavy,
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              image: AssetImage('docs/featured.png'),
              fit: BoxFit.cover,
              opacity: 0.14,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'docs/icon.png',
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operations control',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Manage assets, inspections, shifts, and compliance locally.',
                      style: TextStyle(color: Color(0xFFD8EEF5), height: 1.25),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                MetricCard(
                  width: width,
                  icon: Icons.inventory_2,
                  label: 'Assets ready',
                  value:
                      '${repository.readyAssets}/${repository.assets.length}',
                  color: brandTeal,
                ),
                MetricCard(
                  width: width,
                  icon: Icons.fact_check,
                  label: 'Quality score',
                  value: '${repository.qualityScore}%',
                  color: brandGreen,
                ),
                MetricCard(
                  width: width,
                  icon: Icons.calendar_month,
                  label: 'Live shifts',
                  value: '${repository.todayShifts}',
                  color: brandGold,
                ),
                MetricCard(
                  width: width,
                  icon: Icons.warning_amber,
                  label: 'Open issues',
                  value: '${repository.openIssues}',
                  color: brandRed,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        SectionTitle(
          title: 'Today focus',
          action: repository.settings.siteName,
        ),
        const SizedBox(height: 10),
        StatusStrip(
          icon: Icons.build_circle_outlined,
          title: 'Service attention',
          body: repository.assets
              .where((item) => item.condition == 'Needs service')
              .map((item) => '${item.name} in ${item.zone}')
              .join('\n')
              .ifEmpty('No service exception recorded.'),
          color: brandRed,
        ),
        const SizedBox(height: 10),
        StatusStrip(
          icon: Icons.verified_outlined,
          title: 'Compliance status',
          body: repository.complianceReports
              .map((item) => '${item.title}: ${item.status}')
              .take(2)
              .join('\n'),
          color: brandTeal,
        ),
        const SizedBox(height: 18),
        const SectionTitle(title: 'Recent records'),
        const SizedBox(height: 10),
        ...repository.inspections
            .take(3)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InspectionTile(item: item, onChanged: null),
              ),
            ),
      ],
    );
  }
}

class AssetsPage extends StatelessWidget {
  const AssetsPage({
    super.key,
    required this.repository,
    required this.onAdd,
    required this.onChanged,
  });

  final OperationsRepository repository;
  final VoidCallback onAdd;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: repository.assets.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return PageHeader(
            icon: Icons.inventory_2_outlined,
            title: 'Asset management',
            body:
                '${repository.assets.length} tracked assets with ownership, condition, and service dates.',
            actionLabel: 'New asset',
            onAction: onAdd,
          );
        }
        final asset = repository.assets[index - 1];
        return AssetTile(
          asset: asset,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AssetDetailPage(asset: asset),
              ),
            );
          },
        );
      },
    );
  }
}

class QualityPage extends StatelessWidget {
  const QualityPage({
    super.key,
    required this.repository,
    required this.onAdd,
    required this.onChanged,
  });

  final OperationsRepository repository;
  final VoidCallback onAdd;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: repository.inspections.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return PageHeader(
            icon: Icons.fact_check_outlined,
            title: 'Quality control',
            body:
                '${repository.qualityScore}% average score across inspection areas.',
            actionLabel: 'Record check',
            onAction: onAdd,
          );
        }
        final item = repository.inspections[index - 1];
        return InspectionTile(
          item: item,
          onChanged: (completed) async {
            await repository.toggleInspection(item.id, completed);
            onChanged();
          },
        );
      },
    );
  }
}

class ShiftsPage extends StatelessWidget {
  const ShiftsPage({
    super.key,
    required this.repository,
    required this.onAdd,
    required this.onChanged,
  });

  final OperationsRepository repository;
  final VoidCallback onAdd;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: repository.shifts.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return PageHeader(
            icon: Icons.calendar_month_outlined,
            title: 'Shift scheduling',
            body:
                '${repository.todayShifts} active or planned shifts for the current operating day.',
            actionLabel: 'Add shift',
            onAction: onAdd,
          );
        }
        final shift = repository.shifts[index - 1];
        return ShiftTile(shift: shift);
      },
    );
  }
}

class CompliancePage extends StatelessWidget {
  const CompliancePage({
    super.key,
    required this.repository,
    required this.onAdd,
    required this.onChanged,
  });

  final OperationsRepository repository;
  final VoidCallback onAdd;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: repository.complianceReports.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          final filed = repository.complianceReports
              .where((item) => item.status == 'Filed')
              .length;
          return PageHeader(
            icon: Icons.verified_user_outlined,
            title: 'Compliance reporting',
            body:
                '$filed filed reports with due dates, owners, and local evidence notes.',
            actionLabel: 'New report',
            onAction: onAdd,
          );
        }
        final item = repository.complianceReports[index - 1];
        return ComplianceTile(report: item);
      },
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.repository,
    required this.onChanged,
  });

  final OperationsRepository repository;
  final VoidCallback onChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late WorkspaceSettings settings = widget.repository.settings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workspace settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PageHeader(
            icon: Icons.lock_outline,
            title: 'Local-only workspace',
            body:
                'Records stay on this device. The app has no account, cloud sync, analytics, or external API connection.',
          ),
          const SizedBox(height: 12),
          SettingsTile(
            title: 'Site name',
            subtitle: settings.siteName,
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: 10),
          SettingsTile(
            title: 'Manager',
            subtitle: settings.managerName,
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: settings.localLock,
            onChanged: (value) => _update(settings.copyWith(localLock: value)),
            title: const Text('Require device protection'),
            subtitle: const Text(
              'Reminder to keep records behind Android lock screen.',
            ),
            secondary: const Icon(Icons.phonelink_lock_outlined),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: Colors.white,
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: settings.weeklyDigest,
            onChanged: (value) =>
                _update(settings.copyWith(weeklyDigest: value)),
            title: const Text('Weekly summary reminder'),
            subtitle: const Text('Local reminder preference only.'),
            secondary: const Icon(Icons.summarize_outlined),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: Colors.white,
          ),
          const SizedBox(height: 16),
          const StatusStrip(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy contact',
            body: '$appName\n$supportEmail',
            color: brandTeal,
          ),
        ],
      ),
    );
  }

  Future<void> _update(WorkspaceSettings next) async {
    setState(() => settings = next);
    await widget.repository.updateSettings(next);
    widget.onChanged();
  }
}

class AssetDetailPage extends StatelessWidget {
  const AssetDetailPage({super.key, required this.asset});

  final AssetRecord asset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(asset.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageHeader(
            icon: Icons.precision_manufacturing_outlined,
            title: asset.name,
            body: '${asset.tag} - ${asset.zone}',
          ),
          const SizedBox(height: 12),
          DetailRow(label: 'Condition', value: asset.condition),
          DetailRow(label: 'Owner', value: asset.owner),
          DetailRow(label: 'Next service', value: asset.nextService),
          DetailRow(label: 'Zone', value: asset.zone),
          const SizedBox(height: 12),
          StatusStrip(
            icon: Icons.notes_outlined,
            title: 'Operational note',
            body: asset.note,
            color: asset.condition == 'Ready' ? brandGreen : brandRed,
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  color: brandNavy,
                  fontWeight: FontWeight.w900,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF52616D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: brandInk,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: brandCyan.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: brandCyan),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(color: Color(0xFFD4E6EC), height: 1.3),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add),
                    label: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: brandNavy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: const TextStyle(
              color: Color(0xFF52616D),
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class StatusStrip extends StatelessWidget {
  const StatusStrip({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: brandNavy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(body, style: const TextStyle(height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssetTile extends StatelessWidget {
  const AssetTile({super.key, required this.asset, required this.onTap});

  final AssetRecord asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ready = asset.condition == 'Ready';
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: ready
              ? brandGreen.withValues(alpha: 0.13)
              : brandRed.withValues(alpha: 0.13),
          child: Icon(
            ready ? Icons.check_circle_outline : Icons.build_outlined,
            color: ready ? brandGreen : brandRed,
          ),
        ),
        title: Text(
          asset.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('${asset.tag} - ${asset.zone}\nOwner: ${asset.owner}'),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StatusPill(
              label: asset.condition,
              color: ready ? brandGreen : brandRed,
            ),
            const SizedBox(height: 6),
            Text(
              asset.nextService,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class InspectionTile extends StatelessWidget {
  const InspectionTile({
    super.key,
    required this.item,
    required this.onChanged,
  });

  final InspectionRecord item;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        value: item.completed,
        onChanged: onChanged == null
            ? null
            : (value) => onChanged!(value ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          item.area,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('${item.checklist}\n${item.issue}'),
        secondary: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${item.score}%',
              style: TextStyle(
                color: item.score >= 90 ? brandGreen : brandGold,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(item.date, style: const TextStyle(fontSize: 11)),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class ShiftTile extends StatelessWidget {
  const ShiftTile({super.key, required this.shift});

  final ShiftRecord shift;

  @override
  Widget build(BuildContext context) {
    final active = shift.status == 'Active';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: active
              ? brandTeal.withValues(alpha: 0.12)
              : brandGold.withValues(alpha: 0.14),
          child: Icon(
            active ? Icons.play_circle_outline : Icons.schedule_outlined,
            color: active ? brandTeal : brandGold,
          ),
        ),
        title: Text(
          shift.role,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('${shift.lead}\n${shift.window} - ${shift.coverage}'),
        isThreeLine: true,
        trailing: StatusPill(
          label: shift.status,
          color: active ? brandTeal : brandGold,
        ),
      ),
    );
  }
}

class ComplianceTile extends StatelessWidget {
  const ComplianceTile({super.key, required this.report});

  final ComplianceRecord report;

  @override
  Widget build(BuildContext context) {
    final filed = report.status == 'Filed';
    final color = filed ? brandGreen : brandGold;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.13),
          child: Icon(
            filed ? Icons.verified_outlined : Icons.edit_document,
            color: color,
          ),
        ),
        title: Text(
          report.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${report.owner} - due ${report.dueDate}\n${report.evidence}',
        ),
        isThreeLine: true,
        trailing: StatusPill(label: report.status, color: color),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: brandTeal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF52616D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class AssetFormSheet extends StatefulWidget {
  const AssetFormSheet({super.key});

  @override
  State<AssetFormSheet> createState() => _AssetFormSheetState();
}

class _AssetFormSheetState extends State<AssetFormSheet> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final tag = TextEditingController();
  final zone = TextEditingController();
  final owner = TextEditingController();
  final note = TextEditingController();
  var condition = 'Ready';
  var nextService = 'This week';

  @override
  void dispose() {
    name.dispose();
    tag.dispose();
    zone.dispose();
    owner.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormSheet(
      title: 'Add asset',
      formKey: formKey,
      children: [
        AppTextField(controller: name, label: 'Asset name'),
        AppTextField(controller: tag, label: 'Asset tag'),
        AppTextField(controller: zone, label: 'Zone'),
        AppTextField(controller: owner, label: 'Owner'),
        DropdownButtonFormField<String>(
          initialValue: condition,
          decoration: const InputDecoration(labelText: 'Condition'),
          items: const ['Ready', 'Needs service']
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) => setState(() => condition = value ?? condition),
        ),
        AppTextField(controller: note, label: 'Note', maxLines: 2),
      ],
      onSave: () {
        if (formKey.currentState?.validate() ?? false) {
          Navigator.pop(
            context,
            AssetRecord(
              id: '',
              name: name.text.trim(),
              tag: tag.text.trim(),
              zone: zone.text.trim(),
              owner: owner.text.trim(),
              condition: condition,
              nextService: nextService,
              note: note.text.trim(),
            ),
          );
        }
      },
    );
  }
}

class InspectionFormSheet extends StatefulWidget {
  const InspectionFormSheet({super.key});

  @override
  State<InspectionFormSheet> createState() => _InspectionFormSheetState();
}

class _InspectionFormSheetState extends State<InspectionFormSheet> {
  final formKey = GlobalKey<FormState>();
  final area = TextEditingController();
  final checklist = TextEditingController();
  final issue = TextEditingController();
  var completed = false;
  var score = 90.0;

  @override
  void dispose() {
    area.dispose();
    checklist.dispose();
    issue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormSheet(
      title: 'Record inspection',
      formKey: formKey,
      children: [
        AppTextField(controller: area, label: 'Area'),
        AppTextField(controller: checklist, label: 'Checklist'),
        AppTextField(controller: issue, label: 'Issue or note', maxLines: 2),
        SwitchListTile(
          value: completed,
          onChanged: (value) => setState(() => completed = value),
          title: const Text('Inspection complete'),
          contentPadding: EdgeInsets.zero,
        ),
        Row(
          children: [
            const Text('Score', style: TextStyle(fontWeight: FontWeight.w800)),
            Expanded(
              child: Slider(
                value: score,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${score.round()}%',
                onChanged: (value) => setState(() => score = value),
              ),
            ),
            Text('${score.round()}%'),
          ],
        ),
      ],
      onSave: () {
        if (formKey.currentState?.validate() ?? false) {
          Navigator.pop(
            context,
            InspectionRecord(
              id: '',
              area: area.text.trim(),
              checklist: checklist.text.trim(),
              completed: completed,
              score: score.round(),
              date: 'Today',
              issue: issue.text.trim(),
            ),
          );
        }
      },
    );
  }
}

class ShiftFormSheet extends StatefulWidget {
  const ShiftFormSheet({super.key});

  @override
  State<ShiftFormSheet> createState() => _ShiftFormSheetState();
}

class _ShiftFormSheetState extends State<ShiftFormSheet> {
  final formKey = GlobalKey<FormState>();
  final role = TextEditingController();
  final lead = TextEditingController();
  final window = TextEditingController();
  final coverage = TextEditingController();
  var status = 'Planned';

  @override
  void dispose() {
    role.dispose();
    lead.dispose();
    window.dispose();
    coverage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormSheet(
      title: 'Add shift',
      formKey: formKey,
      children: [
        AppTextField(controller: role, label: 'Role'),
        AppTextField(controller: lead, label: 'Lead'),
        AppTextField(controller: window, label: 'Time window'),
        AppTextField(controller: coverage, label: 'Coverage'),
        DropdownButtonFormField<String>(
          initialValue: status,
          decoration: const InputDecoration(labelText: 'Status'),
          items: const ['Planned', 'Active', 'Closed']
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) => setState(() => status = value ?? status),
        ),
      ],
      onSave: () {
        if (formKey.currentState?.validate() ?? false) {
          Navigator.pop(
            context,
            ShiftRecord(
              id: '',
              role: role.text.trim(),
              lead: lead.text.trim(),
              window: window.text.trim(),
              coverage: coverage.text.trim(),
              status: status,
            ),
          );
        }
      },
    );
  }
}

class ComplianceFormSheet extends StatefulWidget {
  const ComplianceFormSheet({super.key});

  @override
  State<ComplianceFormSheet> createState() => _ComplianceFormSheetState();
}

class _ComplianceFormSheetState extends State<ComplianceFormSheet> {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final owner = TextEditingController();
  final dueDate = TextEditingController();
  final evidence = TextEditingController();
  var status = 'Draft';

  @override
  void dispose() {
    title.dispose();
    owner.dispose();
    dueDate.dispose();
    evidence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormSheet(
      title: 'New report',
      formKey: formKey,
      children: [
        AppTextField(controller: title, label: 'Report title'),
        AppTextField(controller: owner, label: 'Owner'),
        AppTextField(controller: dueDate, label: 'Due date'),
        DropdownButtonFormField<String>(
          initialValue: status,
          decoration: const InputDecoration(labelText: 'Status'),
          items: const ['Draft', 'Review', 'Filed']
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) => setState(() => status = value ?? status),
        ),
        AppTextField(controller: evidence, label: 'Evidence note', maxLines: 2),
      ],
      onSave: () {
        if (formKey.currentState?.validate() ?? false) {
          Navigator.pop(
            context,
            ComplianceRecord(
              id: '',
              title: title.text.trim(),
              owner: owner.text.trim(),
              dueDate: dueDate.text.trim(),
              status: status,
              evidence: evidence.text.trim(),
            ),
          );
        }
      },
    );
  }
}

class FormSheet extends StatelessWidget {
  const FormSheet({
    super.key,
    required this.title,
    required this.formKey,
    required this.children,
    required this.onSave,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: brandNavy,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ...children.expand(
                (child) => [child, const SizedBox(height: 10)],
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
