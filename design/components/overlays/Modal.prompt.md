# Modal

Blocking confirmation dialog (sign out, delete comment). Destructive confirm buttons are red; everything else stays orange/neutral.

```jsx
<Modal open={open} onClose={close} title="Remove account?" actions={<><Button onClick={close}>Cancel</Button><Button variant="danger">Remove</Button></>}>
  gitlab.example.com will be signed out on this device.
</Modal>
```
