# Tab bar

The app's four-destination liquid-glass capsule: floats above the content (which scrolls behind the blur), active item in a lighter glass pill, orange count badge. Give the screen's scroll container ~96px bottom padding for clearance.

```jsx
<TabBar active="todos" onChange={go} items={[
  {id:'home',icon:'home',label:'Home'},
  {id:'todos',icon:'todo-done',label:'To-Dos',badge:3},
  {id:'explore',icon:'compass',label:'Explore'},
  {id:'profile',icon:'user',label:'Profile'}]} />
```
