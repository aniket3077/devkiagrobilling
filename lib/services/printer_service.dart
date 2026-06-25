import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../domain/entities/invoice.dart';
import 'package:intl/intl.dart';

class PrinterService {
  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getPairedDevices() async {
    return await _bluetooth.getBondedDevices();
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      await _bluetooth.connect(device);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> disconnect() async {
    await _bluetooth.disconnect();
  }

  Future<void> printInvoice(Invoice invoice) async {
    bool? isConnected = await _bluetooth.isConnected;
    if (isConnected != true) return;

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    _bluetooth.writeBytes(Uint8List.fromList(generator.text(invoice.customerName, styles: const PosStyles(bold: true, align: PosAlign.center, height: PosTextSize.size2))));
    _bluetooth.writeBytes(Uint8List.fromList(generator.text('INV: ${invoice.invoiceNumber}', styles: const PosStyles(align: PosAlign.center))));
    _bluetooth.writeBytes(Uint8List.fromList(generator.text(DateFormat('dd/MM/yyyy HH:mm').format(invoice.date), styles: const PosStyles(align: PosAlign.center))));
    _bluetooth.writeBytes(Uint8List.fromList(generator.hr()));

    for (var item in invoice.items) {
      _bluetooth.writeBytes(Uint8List.fromList(generator.row([
        PosColumn(text: item.name, width: 7),
        PosColumn(text: '${item.quantity.toInt()}x', width: 2, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: item.total.toStringAsFixed(2), width: 3, styles: const PosStyles(align: PosAlign.right)),
      ])));
    }

    _bluetooth.writeBytes(Uint8List.fromList(generator.hr()));
    _bluetooth.writeBytes(Uint8List.fromList(generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(text: 'Rs ${invoice.grandTotal.toStringAsFixed(2)}', width: 6, styles: const PosStyles(bold: true, align: PosAlign.right)),
    ])));
    
    _bluetooth.writeBytes(Uint8List.fromList(generator.feed(2)));
    _bluetooth.writeBytes(Uint8List.fromList(generator.text('Thank you for shopping!', styles: const PosStyles(align: PosAlign.center))));
    _bluetooth.writeBytes(Uint8List.fromList(generator.feed(1)));
    _bluetooth.writeBytes(Uint8List.fromList(generator.cut()));
  }
}
