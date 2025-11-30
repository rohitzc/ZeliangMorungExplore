export default function Footer() {
  return (
    <footer className="border-t bg-muted/30 py-6 mt-auto">
      <div className="max-w-6xl mx-auto px-4 text-center text-sm text-muted-foreground">
        <p>
          Site developed by{" "}
          <a
            href="https://zeliangcodetech.com"
            target="_blank"
            rel="noopener noreferrer"
            className="text-foreground hover:underline font-medium"
          >
            ZeliangCodeTech
          </a>
        </p>
      </div>
    </footer>
  );
}

