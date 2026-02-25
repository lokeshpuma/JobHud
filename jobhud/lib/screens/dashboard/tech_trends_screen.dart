import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TechTrendsScreen extends StatefulWidget {
  const TechTrendsScreen({super.key});

  @override
  _TechTrendsScreenState createState() => _TechTrendsScreenState();
}

class _TechTrendsScreenState extends State<TechTrendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _random = Random();
  
  // List of all available tech trends (25 unique entries)
  final List<Map<String, String>> _allTrends = [
    {"title": "AI-Powered Development Tools", "description": "AI is revolutionizing how developers write and debug code with tools like GitHub Copilot, Tabnine, and Amazon CodeWhisperer, significantly boosting productivity."},
    {"title": "Quantum Computing Breakthroughs", "description": "Recent advances in quantum computing are enabling solutions for complex problems in cryptography, drug discovery, and optimization that were previously unsolvable."},
    {"title": "Web3 and Decentralized Apps", "description": "The evolution of Web3 is creating a new internet era with decentralized applications, smart contracts, and true digital ownership through blockchain technology."},
    {"title": "Low-Code/No-Code Revolution", "description": "Platforms like Bubble, Webflow, and Adalo are enabling rapid application development with minimal coding, democratizing software creation."},
    {"title": "Progressive Web Apps (PWAs)", "description": "PWAs combine the best of web and mobile apps, offering offline capabilities, push notifications, and app-like experiences without app store distribution."},
    {"title": "Edge Computing Evolution", "description": "Moving computation closer to data sources reduces latency, with applications in IoT, autonomous vehicles, and real-time analytics."},
    {"title": "Cybersecurity Mesh Architecture", "description": "A distributed approach to security that provides a flexible, scalable way to secure all assets, regardless of location."},
    {"title": "Extended Reality (XR) Integration", "description": "The convergence of AR, VR, and MR is transforming industries from healthcare to education with immersive experiences."},
    {"title": "Blockchain Beyond Cryptocurrency", "description": "Blockchain is finding applications in supply chain transparency, digital identity, voting systems, and secure data sharing."},
    {"title": "AI Ethics and Responsible AI", "description": "Focus on developing frameworks and tools to ensure AI systems are fair, transparent, and accountable."},
    {"title": "5G and Next-Gen Connectivity", "description": "The rollout of 5G networks is enabling faster speeds, lower latency, and supporting the growth of IoT and smart cities."},
    {"title": "Sustainable Technology Solutions", "description": "Green computing, energy-efficient data centers, and sustainable software development practices are becoming industry priorities."},
    {"title": "Digital Twins Technology", "description": "Creating virtual replicas of physical systems for simulation, monitoring, and predictive maintenance across industries."},
    {"title": "Natural Language Processing Advances", "description": "Transformers and large language models like GPT-4 are revolutionizing human-computer interaction and content generation."},
    {"title": "Robotic Process Automation (RPA)", "description": "Automating repetitive tasks across business processes to improve efficiency and reduce human error."},
    {"title": "Serverless Computing Growth", "description": "Abstracting infrastructure management to focus on code, with platforms like AWS Lambda and Azure Functions leading the way."},
    {"title": "AI in Cybersecurity", "description": "Leveraging machine learning to detect and respond to security threats in real-time with greater accuracy."},
    {"title": "Cloud-Native Technologies", "description": "Containerization, microservices, and Kubernetes are becoming standard for building scalable, resilient applications."},
    {"title": "AI-Generated Content", "description": "From text to images and videos, AI is transforming content creation across media and entertainment industries."},
    {"title": "Digital Health Tech", "description": "Wearables, telemedicine, and AI diagnostics are reshaping healthcare delivery and patient monitoring."},
    {"title": "Autonomous Systems", "description": "From self-driving cars to drones, autonomous systems are becoming more sophisticated and widely adopted."},
    {"title": "Neuromorphic Computing", "description": "Brain-inspired computing architectures that promise significant improvements in AI processing efficiency."},
    {"title": "Privacy-Enhancing Technologies", "description": "Solutions like homomorphic encryption and federated learning that enable data analysis while preserving privacy."},
    {"title": "Quantum-Safe Cryptography", "description": "Developing new cryptographic algorithms resistant to quantum computing threats to future-proof data security."},
    {"title": "AI-Powered DevOps (AIOps)", "description": "Using AI to enhance software development, testing, and operations through intelligent automation and insights."},
  ];

  List<Map<String, String>> _displayedTrends = [];
  List<Map<String, String>> _savedArticles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedArticles();
    _refreshTrends();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshTrends() {
    setState(() {
      final tempList = List<Map<String, String>>.from(_allTrends);
      tempList.shuffle(_random);
      _displayedTrends = tempList.take(5).toList();
    });
  }

  Future<void> _loadSavedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_articles') ?? [];
    setState(() {
      _savedArticles = saved.map((e) => Map<String, String>.from(json.decode(e))).toList();
    });
  }

  Future<void> _saveArticle(Map<String, String> article) async {
    if (!_savedArticles.any((a) => a['title'] == article['title'])) {
      setState(() {
        _savedArticles.add(article);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'saved_articles',
        _savedArticles.map((a) => json.encode(a)).toList(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article saved successfully')),
      );
    }
  }

  Widget _buildTrendsList() {
    if (_displayedTrends.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _displayedTrends.length,
      itemBuilder: (context, index) {
        final trend = _displayedTrends[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              trend['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(trend['description']!),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () => _saveArticle(trend),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedArticles() {
    if (_savedArticles.isEmpty) {
      return const Center(
        child: Text('No saved articles yet.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _savedArticles.length,
      itemBuilder: (context, index) {
        final article = _savedArticles[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              article['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(article['description']!),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                setState(() {
                  _savedArticles.removeAt(index);
                });
                final prefs = await SharedPreferences.getInstance();
                await prefs.setStringList(
                  'saved_articles',
                  _savedArticles.map((a) => json.encode(a)).toList(),
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Article removed')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tech Trends'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
            Tab(icon: Icon(Icons.bookmark), text: 'Saved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: () async => _refreshTrends(),
            child: _buildTrendsList(),
          ),
          _buildSavedArticles(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _refreshTrends,
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }
}
