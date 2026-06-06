import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const DiskHealthApp());
class DiskHealthApp extends StatelessWidget {
  const DiskHealthApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: '硬盘健康检测', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true, brightness: Brightness.light),
    darkTheme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true, brightness: Brightness.dark),
    home: const DiskHealthHomePage());
}

class DiskInfo {
  final String name, model, serial, interface, firmware;
  final int capacityGB, powerOnHours, powerCycles, temp;
  final double health;
  final String status;
  DiskInfo({required this.name, required this.model, required this.serial, required this.interface, required this.firmware, required this.capacityGB, required this.powerOnHours, required this.powerCycles, required this.temp, required this.health, required this.status});
}

class DiskHealthHomePage extends StatefulWidget {
  const DiskHealthHomePage({super.key});
  @override
  State<DiskHealthHomePage> setState() => _DiskHealthHomePageState();
}

class _DiskHealthHomePageState extends State<DiskHealthHomePage> {
  final _disks = [
    DiskInfo(name: '系统盘', model: 'Samsung 980 PRO 1TB', serial: 'S1234567890', interface: 'NVMe PCIe 4.0', firmware: '5B2QGXA7', capacityGB: 1000, powerOnHours: 2847, powerCycles: 523, temp: 42, health: 96, status: '良好'),
    DiskInfo(name: '数据盘', model: 'WD Blue 2TB', serial: 'WD9876543210', interface: 'SATA III', firmware: '02.01A02', capacityGB: 2000, powerOnHours: 12456, powerCycles: 1024, temp: 38, health: 85, status: '良好'),
    DiskInfo(name: '备份盘', model: 'Seagate 4TB', serial: 'ST4567890123', interface: 'SATA III', firmware: '0001', capacityGB: 4000, powerOnHours: 28760, powerCycles: 2048, temp: 45, health: 62, status: '注意'),
  ];

  DiskInfo? _selected;

  Color _healthColor(double health) => health > 80 ? Colors.green : health > 50 ? Colors.orange : Colors.red;
  Color _tempColor(int temp) => temp < 50 ? Colors.green : temp < 65 ? Colors.orange : Colors.red;

  String _formatHours(int hours) {
    if (hours > 8760) return '${(hours / 8760).toStringAsFixed(1)} 年';
    if (hours > 720) return '${(hours / 720).toStringAsFixed(1)} 月';
    return '$hours 小时';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💾 硬盘健康检测'), centerTitle: true, actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: () {}, tooltip: '刷新'),
      ]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 硬盘列表
        ..._disks.map((disk) => Card(margin: const EdgeInsets.only(bottom: 12), color: _selected?.model == disk.model ? Colors.teal.shade50 : null, child: InkWell(onTap: () => setState(() => _selected = disk), borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: _healthColor(disk.health).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Icon(disk.interface.contains('NVMe') ? Icons.flash_on : Icons.storage, color: _healthColor(disk.health)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(disk.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(disk.model, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${disk.health.toInt()}%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _healthColor(disk.health))),
              Text(disk.status, style: TextStyle(fontSize: 12, color: _healthColor(disk.health))),
            ]),
          ]),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: disk.health / 100, minHeight: 6, backgroundColor: Colors.grey.shade200, color: _healthColor(disk.health))),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildMiniStat('容量', '${disk.capacityGB}GB', Colors.blue),
            _buildMiniStat('通电', _formatHours(disk.powerOnHours), Colors.purple),
            _buildMiniStat('温度', '${disk.temp}°C', _tempColor(disk.temp)),
            _buildMiniStat('接口', disk.interface.contains('NVMe') ? 'NVMe' : 'SATA', Colors.teal),
          ]),
        ]))))),
        const SizedBox(height: 16),
        // 详情
        if (_selected != null) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_selected!.name} 详细信息', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          _infoRow('型号', _selected!.model), _infoRow('序列号', _selected!.serial), _infoRow('接口', _selected!.interface), _infoRow('固件', _selected!.firmware), _infoRow('容量', '${_selected!.capacityGB} GB'), _infoRow('通电时间', '${_selected!.powerOnHours} 小时 (${_formatHours(_selected!.powerOnHours)})'), _infoRow('通电次数', '${_selected!.powerCycles} 次'), _infoRow('当前温度', '${_selected!.temp}°C'), _infoRow('健康度', '${_selected!.health.toInt()}%'), _infoRow('状态', _selected!.status),
        ]))),
        const SizedBox(height: 16),
        // S.M.A.R.T.信息
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('S.M.A.R.T. 关键指标', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildSmartRow('读取错误率', 0, '正常'), _buildSmartRow('通电时间', 2847, '正常'), _buildSmartRow('重新分配扇区', 0, '正常'), _buildSmartRow('寻道错误率', 0, '正常'), _buildSmartRow('温度', 42, '正常'), _buildSmartRow('待映射扇区', 0, '正常'),
        ]))),
      ])),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) => Column(children: [Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)), Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey))]);
  Widget _infoRow(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))), Text(value, style: const TextStyle(fontSize: 13))]));
  Widget _buildSmartRow(String name, dynamic value, String status) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Expanded(child: Text(name, style: const TextStyle(fontSize: 13))), Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(width: 16), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(status, style: const TextStyle(fontSize: 11, color: Colors.green)))]));
}
