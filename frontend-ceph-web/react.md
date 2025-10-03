# Tổng hợp kiến thức react
```
# Các lệnh tắt tạo hàm
rafce
const Header = () => {
  return <h1>Header</h1>;
};

export default Header;

rafc
export const Header = () => {
  return <h1>Header</h1>;
};
// hoặc
// const Header = () => { ... }
// export { Header };

rfc
export function Header() {
  return <h1>Header</h1>;
}
// hoặc
// function Header() { ... }
// export default Header;

# Khác biệt hàm const và function
function : có thể gọi rồi mới gán
const : phải gán rồi mới được gọi

VD : 
bar();                 // OK
function bar() {}

baz();                 // ReferenceError
const baz = () => {};
```