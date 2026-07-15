import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RulesWebViewScreen extends StatefulWidget {
  const RulesWebViewScreen({super.key});

  @override
  State<RulesWebViewScreen> createState() => _RulesWebViewScreenState();
}

class _RulesWebViewScreenState extends State<RulesWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F172A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      );

    // Bypasses asset bundles entirely and renders directly from memory
    _controller.loadHtmlString(_htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Futsal Dai Guidelines',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF39FF14)),
              ),
            ),
        ],
      ),
    );
  }
}

// Store the HTML here at the bottom of the file as a multiline Dart string
const String _htmlContent = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Futsal Dai - Book Pitches, Play Matches</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --bg-slate: #0F172A;
            --surface-slate: #1E293B;
            --neon-lime: #39FF14;
            --neon-lime-dim: rgba(57, 255, 20, 0.15);
            --electric-amber: #F59E0B;
            --electric-amber-dim: rgba(245, 158, 11, 0.1);
            --text-primary: #FFFFFF;
            --text-secondary: #94A3B8;
        }
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        }
        body {
            background-color: var(--bg-slate);
            color: var(--text-primary);
            line-height: 1.6;
        }
        .container {
            max-width: 1100px;
            margin: 0 auto;
            padding: 0 20px;
        }
        header {
            padding: 20px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            position: sticky;
            top: 0;
            z-index: 100;
            background-color: rgba(15, 23, 42, 0.9);
        }
        .nav-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo {
            font-size: 24px;
            font-weight: 800;
            color: var(--text-primary);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .logo span {
            color: var(--neon-lime);
        }
        .nav-links {
            display: flex;
            gap: 24px;
        }
        .nav-links a {
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: color 0.3s;
        }
        .nav-links a:hover {
            color: var(--neon-lime);
        }
        .hero {
            padding: 80px 0;
            text-align: center;
            background: radial-gradient(circle at top, rgba(57, 255, 20, 0.05) 0%, transparent 60%);
        }
        .hero h1 {
            font-size: 48px;
            font-weight: 800;
            margin-bottom: 16px;
            letter-spacing: -1px;
        }
        .hero h1 span {
            color: var(--neon-lime);
            text-shadow: 0 0 15px rgba(57, 255, 20, 0.3);
        }
        .hero p {
            font-size: 18px;
            color: var(--text-secondary);
            max-width: 600px;
            margin: 0 auto 32px auto;
        }
        .cta-btn {
            display: inline-block;
            background-color: var(--neon-lime);
            color: #000;
            font-weight: 700;
            padding: 14px 28px;
            border-radius: 8px;
            text-decoration: none;
            transition: transform 0.2s, box-shadow 0.2s;
            box-shadow: 0 4px 14px rgba(57, 255, 20, 0.4);
        }
        .cta-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(57, 255, 20, 0.6);
        }
        .guidelines-section {
            padding: 60px 0 100px 0;
        }
        .section-header {
            text-align: center;
            margin-bottom: 48px;
        }
        .section-header h2 {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 8px;
        }
        .section-header p {
            color: var(--text-secondary);
        }
        .grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 24px;
            margin-bottom: 40px;
        }
        @media (min-width: 768px) {
            .grid {
                grid-template-columns: 1fr 1fr;
            }
        }
        .card {
            background-color: var(--surface-slate);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 12px;
            padding: 28px;
            position: relative;
            overflow: hidden;
        }
        .card.active-border {
            border-color: var(--neon-lime);
        }
        .card.amber-border {
            border-color: var(--electric-amber);
        }
        .card h3 {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .card h3 i {
            font-size: 18px;
        }
        .card p, .card li {
            color: var(--text-secondary);
            font-size: 14px;
            margin-bottom: 12px;
        }
        .card ul {
            list-style: none;
            padding-left: 0;
        }
        .card li {
            display: flex;
            align-items: flex-start;
            gap: 8px;
            margin-bottom: 8px;
        }
        .card li i {
            margin-top: 4px;
            font-size: 12px;
        }
        .badge {
            display: inline-flex;
            align-items: center;
            font-size: 11px;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 12px;
            margin-bottom: 16px;
        }
        .badge.lime {
            background-color: var(--neon-lime-dim);
            color: var(--neon-lime);
        }
        .badge.amber {
            background-color: var(--electric-amber-dim);
            color: var(--electric-amber);
        }
        footer {
            background-color: #0B101D;
            padding: 40px 0;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            text-align: center;
            font-size: 14px;
            color: var(--text-secondary);
        }
        footer p {
            margin-bottom: 8px;
        }
        footer a {
            color: var(--neon-lime);
            text-decoration: none;
        }
    </style>
</head>
<body>
    <header>
        <div class="container nav-container">
            <a href="#" class="logo">
                <i class="fa-solid fa-circle-play" style="color: var(--neon-lime);"></i> Futsal <span>Dai</span>
            </a>
            <nav class="nav-links">
                <a href="#rules">Rules</a>
                <a href="#support">Support</a>
            </nav>
        </div>
    </header>
    <section class="hero">
        <div class="container">
            <h1>Claim Your Pitch with <span>Futsal Dai</span></h1>
            <p>The ultimate booking playground. Zero spam, instant coordinates, and direct lines to the best turfs in town.</p>
            <a href="#rules" class="cta-btn">View Fair Play Rules</a>
        </div>
    </section>
    <section id="rules" class="guidelines-section">
        <div class="container">
            <div class="section-header">
                <h2>Fair Play & Anti-Spam Guidelines</h2>
                <p>Simple rules to keep the beautiful game fair for players and turf owners.</p>
            </div>
            <div class="grid">
                <div class="card">
                    <h3><i class="fa-solid fa-shield-halved" style="color: var(--neon-lime);"></i> 1. Zero Booking Abuse</h3>
                    <p>We enforce strict policies to make sure pitches don't sit empty while active teams miss out:</p>
                    <ul>
                        <li><i class="fa-solid fa-ban" style="color: #ef4444;"></i> <strong>Slot Hoarding:</strong> Booking multiple pitches at once to decide later is strictly banned.</li>
                        <li><i class="fa-solid fa-circle-exclamation" style="color: #ef4444;"></i> <strong>No-Show Penalty:</strong> Missing a confirmed match flags your profile instantly.</li>
                    </ul>
                </div>
                <div class="card amber-border">
                    <div class="badge amber">⚠️ Pending State</div>
                    <h3><i class="fa-solid fa-phone-volume" style="color: var(--electric-amber);"></i> 2. Call-to-Verify System</h3>
                    <p>For venues without instant digital prepayments:</p>
                    <ul>
                        <li><i class="fa-solid fa-clock"></i> The slot is held as "Pending" for exactly <strong>15 minutes</strong>.</li>
                        <li><i class="fa-solid fa-mobile-screen"></i> The venue manager will call your registered phone to finalize the match.</li>
                        <li><i class="fa-solid fa-circle-xmark"></i> Unreachable numbers trigger automatic slot expiration.</li>
                    </ul>
                </div>
                <div class="card active-border">
                    <div class="badge lime">⚡ Elite Status</div>
                    <h3><i class="fa-solid fa-gauge-high" style="color: var(--neon-lime);"></i> 3. Player Reliability Score</h3>
                    <p>Your digital football card updates with your play history:</p>
                    <ul>
                        <li><i class="fa-solid fa-circle-check" style="color: var(--neon-lime);"></i> Keeping a score above <strong>95%</strong> grants you Elite Booker benefits.</li>
                        <li><i class="fa-solid fa-triangle-exclamation" style="color: var(--electric-amber);"></i> Dropping below <strong>70%</strong> locks Pay-at-Venue permissions.</li>
                    </ul>
                </div>
                <div id="support" class="card">
                    <h3><i class="fa-solid fa-headset" style="color: var(--neon-lime);"></i> 4. Quick Support Squad</h3>
                    <p>Double booking? Tech bug? Disputes are handled within 2 hours on match days:</p>
                    <ul>
                        <li><i class="fa-regular fa-envelope"></i> Email: <a href="mailto:support@futsaldai.com" style="color: var(--neon-lime);">support@futsaldai.com</a></li>
                        <li><i class="fa-solid fa-phone"></i> Player Line: +977-1-XXXXXXX</li>
                    </ul>
                </div>
            </div>
        </div>
    </section>
    <footer>
        <div class="container">
            <p>&copy; 2026 Futsal Dai. Let's keep the game beautiful.</p>
            <p>Made for the Nepalese football community.</p>
        </div>
    </footer>
</body>
</html>
""";