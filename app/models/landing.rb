module Landing
  FEATURES = [
    { icon: :eye, title: "AI Visibility Tracking",
      desc: "Monitor how often your brand appears across ChatGPT, Claude, Google AI and Perplexity." },
    { icon: :trophy, title: "Competitor Benchmarking",
      desc: "See exactly who is winning AI search in your category and where you are losing ground." },
    { icon: :message, title: "Prompt Monitoring",
      desc: "Track your rankings for the high-intent prompts your buyers actually ask." },
    { icon: :sparkles, title: "AI SEO Recommendations",
      desc: "Receive prioritized, actionable improvements ranked by projected visibility impact." },
    { icon: :trending, title: "Historical Analytics",
      desc: "Measure visibility growth over time and prove the ROI of your AI search efforts." },
    { icon: :eye, title: "Citation Discovery",
      desc: "Find every page and source AI assistants cite when talking about your category." }
  ].freeze

  HERO_PLATFORMS = [
    { name: "ChatGPT", vis: 82, color: "#0e9c8e" },
    { name: "Claude", vis: 74, color: "#5b41f0" },
    { name: "Google AI", vis: 61, color: "#2c7fc0" },
    { name: "Perplexity", vis: 58, color: "#c07d0a" }
  ]

  VISIBILITY_SCORE = 78

  LOGOS = [ "Northwind", "Lumen", "Cadre", "Vantage", "Foundry" ]


  PREVIEW_TABS = [ "Overview", "Competitors", "Prompts", "Reports" ]
  
  PREVIEW_STATS = [
    { label: "AI mentions", value: "1,248", delta: "+18%" },
    { label: "Citations earned", value: "448", delta: "+9%" },
    { label: "Prompts won", value: "2 / 6", delta: "+2" }
  ]
  CHART_DATA = [ 52, 55, 57, 60, 62, 65, 68, 70, 73, 75, 77, 78 ]

  PRICING_PLANS = [
    { name: "Starter", blurb: "For individuals and side projects.", monthly: 59, annual: 49,
      cta: "Start free trial", highlight: false,
      features: [ "50 tracked prompts", "3 competitors", "3 AI platforms", "Weekly scans", "Email support" ] },
    { name: "Growth", blurb: "For growing marketing teams.", monthly: 179, annual: 149,
      cta: "Start free trial", highlight: true,
      features: [ "250 tracked prompts", "10 competitors", "All 5 AI platforms", "Daily scans", "API access", "Priority support" ] },
    { name: "Enterprise", blurb: "For large organizations.", monthly: nil, annual: nil,
      cta: "Contact sales", highlight: false,
      features: [ "Unlimited prompts", "Unlimited competitors", "SSO & SAML", "Dedicated manager", "Custom integrations", "SLA & security review" ] }
  ]

  FAQS = [
    { q: "What is AI visibility?",
      a: "AI visibility measures how often and how prominently your brand appears when people ask AI assistants like ChatGPT and Claude questions related to your category — the new frontier of search." },
    { q: "Which AI platforms are supported?",
      a: "Renkley tracks ChatGPT, Claude, Google AI Overviews and Perplexity today, with new AI search experiences added regularly." },
    { q: "How often is data updated?",
      a: "Visibility scans run daily on Growth and Enterprise plans, and weekly on Starter. Enterprise customers can request custom scan frequencies." },
    { q: "How do competitor comparisons work?",
      a: "Add the brands you compete with and Renkley benchmarks their AI visibility, mentions and citations against yours across every tracked platform." },
    { q: "Can I export reports?",
      a: "Yes. Every dashboard exports to PDF and CSV, and you can schedule automated reports to be emailed to your team and stakeholders." },
    { q: "Is there an API?",
      a: "Growth and Enterprise plans include full API access so you can pull visibility data into your own dashboards and workflows." },
    { q: "Do you offer enterprise plans?",
      a: "Yes — Enterprise includes SSO, a dedicated success manager, custom integrations and unlimited tracking. Contact sales for a tailored quote." }
  ]

end
