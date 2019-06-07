export default function (state = {}, action) {
	console.log('This is action ', action);
	switch(action.type) {
		case "USER_SELECTED":
		console.log('a: ',action);
			return { ...state, activeUser: action.PAYLOAD.first }
			break;
	}
	return state;
}