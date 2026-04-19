import 'package:flutter/material.dart';
import 'package:medconnect_app/core/app_colorSupplier.dart';
import 'package:medconnect_app/models/supplier_product.dart';

class SupplierProfileScreen extends StatelessWidget {
  SupplierProfileScreen({super.key});

  final List<SupplierProduct> supplierProducts = [
    SupplierProduct(
      name: "Ultrasound Machine",
      category: "Diagnostic Imaging",
      price: "\$15,000",
      image:
          "https://lh3.googleusercontent.com/aida-public/AB6AXuAm0WYodkvY4uV9HPe2XSEhue_52XPtKxVm1n9DCdJcCboff6BZw3UKLAJdzgREaJpgO_CMUKwcDCMo1pmV6ynKDSpXVFMNTYQ3ReG1a57cE79L8O6WMbjAuuw3Tso2Lapth76Wd98siwZGPEEM_7QVnBnaJtlXiqOGj4v6MIctb39B_tieZzj7l42QMvmc6-GqUqrRQoi_rX3KT0s9g8BWO15xHsTPBQw-gbtFBlrQPFMWuLPRZZj9R2eaP_75t1j27IYVQFHBDa0",
      action: ProductAction.addToCart,
    ),
    SupplierProduct(
      name: "ECG Monitor",
      category: "Patient Monitoring",
      price: "Available in 2 days",
      image:
          "https://lh3.googleusercontent.com/aida-public/AB6AXuBaHb2WHaBpbz4e7WZauL8XP1Tl27alU5YxUYOfrp0hvYqrERXrS9Yv-wNS-dg4jhta88NyIgtw0T84IHe742ddjXjaHDiN2w8cMx2wTljLQ0fmQKAmdaNUUd6xwtX2WuAq0g-PogYXdWhYSRwzrnOkwKpmOxfNKhAbPBnWJbPMX3K4ZHBv9GpL-kMNzTogOFdcab9wagu9A41JYWDa2jvDCq_C-iy20xODVW09BWicm_c8z3UyScwpkUGdjUQByQdzC9fb7v7CmSA",
      action: ProductAction.notify,
    ),
    SupplierProduct(
      name: "Surgical Lights",
      category: "Operating Room",
      price: "\$4,500",
      subtitle: "or \$800/mo",
      image:
          "https://lh3.googleusercontent.com/aida-public/AB6AXuCnrlF8dIQzoB8FCdsCdYUCS83eyJ4lLhu-oi1Q7KkuxMt99R03LizzgU3BgPTCQwPKmCESpYd56oJUYPW1bJ5mT2xEgeYRknNTQT1Oiw7NVy8_llimxcCmQl_-AUIDWFEufj_kkcYxOYTzHng1CC407plg6fnFIVKa116zeY1bxJGBiEj7ujAScqnncCqS_Tp0erzCsNscbJiJa9otrIrPSROdi46LqGHDiY884KL5nPr2znLOB5MUm765IexJvaJY32_JW4dpXds",
      action: ProductAction.rentBuy,
    ),
    SupplierProduct(
      name: "Anesthesia Machine",
      category: "Surgical Equipment",
      price: "\$22,000",
      image:
          "https://lh3.googleusercontent.com/aida-public/AB6AXuBUJ97EQNRgw4iWB8PExb274u5BeHNzwvk9oxAofMtFEbktJwH6iJf-vKzZ3t3Pswd7kNoIg7mz_Me5picTmVZ0FkKSirmm8_nsLewQYwITq5-bHlwzmb0a-CbkU5nIfVR6Tom54eAa9561f9b7Z0QKrePWVYIY4jI0D4AXNlBi0UNrIYI59VgeeECHBUndzsetPKdSGwnJHZINKvob0obhjDVNY8_aehqDGFu5aJTd7uFGOFg4lJWmW6YQU1L68t3691_qugIKz_Y",
      action: ProductAction.addToCart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _supplierHeader(),
                    _aboutSection(),
                    _achievements(),
                    _certificates(),
                    _productsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TOP BAR ----------------
  Widget _topBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Supplier Profile",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
  // ---------------- HEADER ----------------
  Widget _supplierHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 56,
            backgroundImage: NetworkImage(
              "https://lh3.googleusercontent.com/aida-public/AB6AXuB8BwL71-RHv3rXvf-HKFlFKMs35aXimftEGW17kNnyokeW_eVI3I8XG2wqaDRQNkqkaTlQ7XryvkmIEEWK6h8AKsPjALIEFuoSZNP2niRm61MSToXhy5Zy94-STbAXfd6meGtSED2zmuk34Zzowla0tX9pu4Pu-D02OE9tro7Qg2GbI2As9zmUqX31IHjFyR69ktYbApJQtWtJWiyZYC-SIPcjpcLBuQYTaPM4zriiWlhhxINRTcTBeT0IwIWTyESig5Q2ttvWkg0",
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "MediTech Solutions Inc.",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Innovating Medical Technology since 1998",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Chat with Vendor",
                style: TextStyle(fontWeight: FontWeight.bold , color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
 // ---------------- ABOUT ----------------
  Widget _aboutSection() {
    return _card(
      title: "About Us",
      child: const Text(
        "MediTech Solutions Inc. is a leading provider of state-of-the-art medical equipment. Our mission is to enhance patient care by supplying reliable and innovative devices to healthcare professionals worldwide.",
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  // ---------------- ACHIEVEMENTS ----------------
  Widget _achievements() {
    return _card(
      title: "Key Achievements",
      child: Row(
        children: [
          _achievementItem("25+", "Years of Innovation"),
          const SizedBox(width: 12),
          _achievementItem("500+", "Partner Hospitals"),
        ],
      ),
    );
  }
   Widget _achievementItem(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  // ---------------- CERTIFICATES ----------------
  Widget _certificates() {
    return _card(
      title: "Certificates",
      child: Column(
        children: const [
          certificateItem("ISO 13485 Certified"),
          certificateItem("CE Marking for Medical Devices"),
          certificateItem("FDA 510(k) Clearance"),
        ],
      ),
    );
  }


  // ---------------- PRODUCTS ----------------
  Widget _productsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "All Products by this Supplier",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "See all",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...supplierProducts
            .map((product) => _productCard(product))
            .toList(),
      ],
    );
  }

  Widget _productCard(SupplierProduct product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.image,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.category,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                Text(product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  product.price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: product.action == ProductAction.notify
                        ? Colors.amber
                        : AppColors.primary,
                  ),
                ),
                if (product.subtitle != null)
                  Text(
                    product.subtitle!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          productActionButton(product.action),
        ],
      ),
    );
  }

  Widget productActionButton(ProductAction action) {
    switch (action) {
      case ProductAction.addToCart:
        return ElevatedButton(
          onPressed: () {},
          child: const Text("Add to Cart", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        );
      case ProductAction.notify:
        return ElevatedButton(
          onPressed: () {},
          child: const Text("Notify Me", style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
        );
      case ProductAction.rentBuy:
        return Column(
          children: [
            ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white70),
                      onPressed: () {},
                      child: const Text("Rent", style: TextStyle(color: Colors.blue)),
            ),
            const SizedBox(height: 6),
            ElevatedButton(onPressed: () {},
            child: const Text("Buy", style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue)),
          ],
        );
    }
  }
}
// ---------------- COMMON CARD ----------------
  Widget _card({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }


// ---------------- CERTIFICATE ITEM ----------------
class certificateItem extends StatelessWidget {
  final String text;
  const certificateItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.verified, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
