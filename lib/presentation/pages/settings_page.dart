import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../../services/printer_service.dart';
import '../../injection_container.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: '');
  final _addressController = TextEditingController(text: '');
  final _phoneController = TextEditingController(text: '');
  final _emailController = TextEditingController(text: '');
  final _gstController = TextEditingController(text: '');

  final PrinterService _printerService = sl<PrinterService>();
  List<BluetoothDevice> _pairedDevices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnecting = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadPairedDevices();
  }

  Future<void> _loadPairedDevices() async {
    final devices = await _printerService.getPairedDevices();
    setState(() {
      _pairedDevices = devices;
    });
  }

  Future<void> _connectPrinter(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
    });
    final success = await _printerService.connect(device);
    setState(() {
      _isConnecting = false;
      _isConnected = success;
      if (success) {
        _selectedDevice = device;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Printer connected successfully!' : 'Failed to connect printer'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _disconnectPrinter() async {
    await _printerService.disconnect();
    setState(() {
      _isConnected = false;
      _selectedDevice = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Printer disconnected')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Business Profile Card
            Expanded(
              flex: 3,
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE6EFEA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Business Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Set up your store details for invoices and billing receipts.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Business Name *', border: OutlineInputBorder()),
                          validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Store Address *', border: OutlineInputBorder()),
                          validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(labelText: 'Contact Phone *', border: OutlineInputBorder()),
                                validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(labelText: 'Contact Email', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _gstController,
                          decoration: const InputDecoration(labelText: 'GSTIN (Tax Registration Number) *', border: OutlineInputBorder()),
                          validator: (val) => val == null || val.isEmpty ? 'Required field' : null,
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Business profile updated successfully!')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('SAVE PROFILE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),

            // Right Column: Printer / Bluetooth setup
            Expanded(
              flex: 2,
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE6EFEA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thermal Printer Integration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Connect your ESC/POS bluetooth thermal printer (58mm/80mm) to print receipts.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(height: 24),

                      // Current Connection Status
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isConnected ? Theme.of(context).colorScheme.primaryContainer : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _isConnected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isConnected ? Icons.print : Icons.print_disabled,
                              color: _isConnected ? Colors.green : Colors.grey,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isConnected ? 'Connected' : 'Disconnected',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _isConnected ? Colors.green[800] : Colors.grey[700],
                                    ),
                                  ),
                                  if (_isConnected && _selectedDevice != null)
                                    Text(_selectedDevice!.name ?? 'Unknown Device', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            if (_isConnected)
                              TextButton(
                                onPressed: _disconnectPrinter,
                                child: const Text('DISCONNECT', style: TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Paired Devices', style: TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
                            onPressed: _loadPairedDevices,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_pairedDevices.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(child: Text('No paired bluetooth devices found. Pair a printer in device settings first.')),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _pairedDevices.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final device = _pairedDevices[index];
                            final isConnectingThis = _isConnecting && _selectedDevice == device;
                            return ListTile(
                              leading: const Icon(Icons.bluetooth),
                              title: Text(device.name ?? 'Unknown Device'),
                              subtitle: Text(device.address ?? ''),
                              trailing: isConnectingThis
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                  : ElevatedButton(
                                      onPressed: () => _connectPrinter(device),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                        foregroundColor: Theme.of(context).colorScheme.primary,
                                        elevation: 0,
                                      ),
                                      child: const Text('CONNECT'),
                                    ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
