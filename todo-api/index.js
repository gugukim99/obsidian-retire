// Windows 콘솔 UTF-8 출력 설정
if (process.stdout.setDefaultEncoding) {
  process.stdout.setDefaultEncoding('utf8');
}

const app = require('./app');

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Todo API server running on port ${PORT}`);
});
