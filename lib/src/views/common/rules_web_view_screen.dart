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
    <title>Futsal Dai - Support & Community Guidelines</title>
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
        .block-heading {
            font-size: 24px;
            font-weight: 800;
            margin: 48px 0 20px 0;
            display: flex;
            align-items: center;
            gap: 10px;
            color: var(--text-primary);
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
                <a href="#rules">Guidelines</a>
                <a href="#support">Support</a>
            </nav>
        </div>
    </header>
    <section class="hero">
        <div class="container">
            <h1>Play Fair. Stay <span>Connected</span>.</h1>
            <p>Community, support & anti-spam guidelines to keep Futsal Dai safe, fair, and spam-free for players and turf owners.</p>
            <a href="#support" class="cta-btn">Contact Support</a>
        </div>
    </section>

    <section id="rules" class="guidelines-section">
        <div class="container">
            <div class="section-header">
                <h2>Community Guidelines</h2>
                <p>Simple rules that keep the beautiful game fair for everyone.</p>
            </div>

            <h3 class="block-heading"><i class="fa-solid fa-envelope-circle-check" style="color: var(--neon-lime);"></i> Anti-Spam Rules</h3>
            <div class="grid">
                <div class="card">
                    <h3><i class="fa-solid fa-ban" style="color: var(--neon-lime);"></i> Zero Booking Abuse</h3>
                    <ul>
                        <li><i class="fa-solid fa-ban" style="color: #ef4444;"></i> <strong>Slot Hoarding:</strong> Booking multiple pitches at once to decide later is prohibited.</li>
                        <li><i class="fa-solid fa-clock" style="color: var(--electric-amber);"></i> <strong>No-Show Penalty:</strong> Missing a confirmed match flags your profile and lowers your reliability score.</li>
                        <li><i class="fa-solid fa-repeat" style="color: var(--electric-amber);"></i> <strong>Repeated Cancellations:</strong> Habitual last-minute cancellations may restrict booking ability.</li>
                    </ul>
                </div>
                <div class="card amber-border">
                    <h3><i class="fa-solid fa-phone-volume" style="color: var(--electric-amber);"></i> Call-to-Verify</h3>
                    <ul>
                        <li><i class="fa-solid fa-clock"></i> Slots are held as "Pending" for a set window until confirmed.</li>
                        <li><i class="fa-solid fa-mobile-screen"></i> Venue managers may call your registered number to finalize.</li>
                        <li><i class="fa-solid fa-circle-xmark"></i> Unreachable or invalid numbers trigger automatic slot release.</li>
                        <li><i class="fa-solid fa-circle-check" style="color: var(--neon-lime);"></i> Only use real, contactable phone numbers.</li>
                    </ul>
                </div>
                <div class="card">
                    <h3><i class="fa-solid fa-user-shield" style="color: var(--neon-lime);"></i> No Misuse of Features</h3>
                    <ul>
                        <li><i class="fa-solid fa-bullhorn"></i> <strong>Mercenary Board:</strong> Post only genuine match-day recruitment, no promotional spam.</li>
                        <li><i class="fa-solid fa-people-group"></i> <strong>Groups:</strong> Do not mass-invite strangers or create duplicate spam groups.</li>
                        <li><i class="fa-solid fa-star"></i> <strong>Reviews/Messages:</strong> No fake reviews, self-boosting, or flooding messages to venues or players.</li>
                    </ul>
                </div>
                <div class="card active-border">
                    <div class="badge lime">⚡ Continuous Protection</div>
                    <h3><i class="fa-solid fa-gauge-high" style="color: var(--neon-lime);"></i> Player Reliability Score</h3>
                    <ul>
                        <li><i class="fa-solid fa-circle-check" style="color: var(--neon-lime);"></i> Score above <strong>95%</strong> keeps Elite Booker benefits.</li>
                        <li><i class="fa-solid fa-triangle-exclamation" style="color: var(--electric-amber);"></i> Dropping below <strong>70%</strong> may restrict Pay-at-Venue options.</li>
                        <li><i class="fa-solid fa-chart-line"></i> The score reflects on-time attendance, cancellations, and no-shows.</li>
                    </ul>
                </div>
            </div>

            <h3 class="block-heading"><i class="fa-solid fa-handshake-angle" style="color: var(--electric-amber);"></i> Anti-Abuse & Conduct</h3>
            <div class="grid">
                <div class="card">
                    <h3><i class="fa-solid fa-user-lock" style="color: var(--neon-lime);"></i> Prohibited Behavior</h3>
                    <ul>
                        <li><i class="fa-solid fa-ban" style="color: #ef4444;"></i> Harassment, hate speech, discrimination, or threats.</li>
                        <li><i class="fa-solid fa-ban" style="color: #ef4444;"></i> Impersonating other players, venues, or Futsal Dai staff.</li>
                        <li><i class="fa-solid fa-ban" style="color: #ef4444;"></i> Creating fake accounts or manipulating scores/attendance.</li>
                        <li><i class="fa-solid fa-ban" style="color: #ef4444;"></i> Sharing others' personal data without consent.</li>
                    </ul>
                </div>
                <div class="card">
                    <h3><i class="fa-solid fa-shield-halved" style="color: var(--neon-lime);"></i> Safe Play Environment</h3>
                    <ul>
                        <li><i class="fa-solid fa-circle-info"></i> Keep match attendance and group roles accurate.</li>
                        <li><i class="fa-solid fa-flask" style="color: var(--electric-amber);"></i> Guest and mercenary players must be disclosed honestly to the group.</li>
                        <li><i class="fa-solid fa-flag" style="color: var(--electric-amber);"></i> Report unsafe, fraudulent, or suspicious activity to support.</li>
                    </ul>
                </div>
                <div class="card amber-border">
                    <div class="badge amber">⚠️ Account Standards</div>
                    <h3><i class="fa-solid fa-id-badge" style="color: var(--electric-amber);"></i> Honest Accounts</h3>
                    <ul>
                        <li><i class="fa-solid fa-circle-check" style="color: var(--neon-lime);"></i> Provide accurate name, phone, and profile details.</li>
                        <li><i class="fa-solid fa-circle-xmark" style="color: #ef4444;"></i> One account per person; no account sharing or selling.</li>
                        <li><i class="fa-solid fa-triangle-exclamation" style="color: var(--electric-amber);"></i> Inactive or suspicious accounts may face verification.</li>
                    </ul>
                </div>
                <div class="card">
                    <h3><i class="fa-solid fa-flag" style="color: var(--neon-lime);"></i> Reporting</h3>
                    <p>Any player or owner can report abuse, spam, or unsafe content directly through the app or support. Reports are confidential and reviewed promptly.</p>
                </div>
            </div>

            <h3 class="block-heading"><i class="fa-solid fa-scale-balanced" style="color: var(--neon-lime);"></i> Enforcement & Consequences</h3>
            <div class="grid">
                <div class="card active-border">
                    <div class="badge lime">1</div>
                    <h3><i class="fa-solid fa-bell" style="color: var(--neon-lime);"></i> Warning</h3>
                    <p>Minor or first-time issues receive a written warning outlining the rule broken and expected behavior going forward.</p>
                </div>
                <div class="card">
                    <div class="badge amber">2</div>
                    <h3><i class="fa-solid fa-gavel" style="color: var(--electric-amber);"></i> Suspension</h3>
                    <p>Repeated or serious violations lead to a temporary suspension of booking, group, or account features.</p>
                </div>
                <div class="card amber-border">
                    <div class="badge amber">3</div>
                    <h3><i class="fa-solid fa-user-xmark" style="color: var(--electric-amber);"></i> Permanent Ban</h3>
                    <p>Severe abuse &mdash; fraud, harassment, impersonation, or platform misuse &mdash; results in a permanent account ban.</p>
                </div>
                <div class="card">
                    <div class="badge lime">4</div>
                    <h3><i class="fa-solid fa-rotate-right" style="color: var(--neon-lime);"></i> Appeals</h3>
                    <p>You may appeal any enforcement action by contacting support with your case details. We review appeals fairly within a reasonable time.</p>
                </div>
            </div>

            <div id="support" class="section-header" style="margin-top: 60px;">
                <h2>Support & Help Center</h2>
                <p>We're here to help you book, play, and resolve issues quickly.</p>
            </div>
            <div class="grid">
                <div class="card active-border">
                    <h3><i class="fa-solid fa-headset" style="color: var(--neon-lime);"></i> Contact Support</h3>
                    <ul>
                        <li><i class="fa-regular fa-envelope"></i> Email: <a href="mailto:support@futsaldai.com" style="color: var(--neon-lime);">support@futsaldai.com</a></li>
                        <li><i class="fa-solid fa-phone"></i> Player Support Line: +977-1-XXXXXXX</li>
                        <li><i class="fa-solid fa-building-shield"></i> Owner / Venue Support: dedicated portal line</li>
                    </ul>
                </div>
                <div class="card">
                    <h3><i class="fa-solid fa-clock" style="color: var(--neon-lime);"></i> Response Times</h3>
                    <ul>
                        <li><i class="fa-solid fa-circle-check" style="color: var(--neon-lime);"></i> Booking disputes handled within <strong>2 hours</strong> on match days.</li>
                        <li><i class="fa-solid fa-circle-check" style="color: var(--neon-lime);"></i> General queries answered within <strong>24 hours</strong>.</li>
                        <li><i class="fa-solid fa-sun"></i> Peak-hour priority for urgent match-day issues.</li>
                    </ul>
                </div>
                <div class="card">
                    <h3><i class="fa-solid fa-circle-question" style="color: var(--neon-lime);"></i> What We Can Help With</h3>
                    <ul>
                        <li><i class="fa-solid fa-circle-check"></i> Double bookings & slot conflicts</li>
                        <li><i class="fa-solid fa-circle-check"></i> Payment, refund, and transaction issues</li>
                        <li><i class="fa-solid fa-circle-check"></i> Account & profile problems</li>
                        <li><i class="fa-solid fa-circle-check"></i> Reporting abuse, spam, or safety concerns</li>
                        <li><i class="fa-solid fa-circle-check"></i> Venue & group setup assistance</li>
                    </ul>
                </div>
                <div class="card">
                    <h3><i class="fa-solid fa-file-shield" style="color: var(--neon-lime);"></i> Your Responsibilities</h3>
                    <ul>
                        <li><i class="fa-solid fa-circle-info"></i> Provide accurate information when contacting support.</li>
                        <li><i class="fa-solid fa-circle-info"></i> Use support channels respectfully &mdash; no harassment of staff.</li>
                        <li><i class="fa-solid fa-circle-info"></i> Keep your login and account credentials secure.</li>
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