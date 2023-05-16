function Form(props) {
  const [name, setName] = useState("form");
  
  return (
    <form>
      <input type="text" value={name}/>
    </form>
  )
}

export default Form;