interface Person {
    age: number,
    name: string,
    say(): string
}

function sayIt(person: Person) {
    return person.say();
}

export default sayIt;