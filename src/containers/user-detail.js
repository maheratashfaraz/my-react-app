import React, {Component} from 'react';
import {connect} from 'react-redux';

class UserDetail extends Component {
	render() {
		console.log('This is the user detail ', this.props.user);
		console.log('this.props', this.props)
		if (!this.props.user) {
			return (<h4>select a user ...</h4>);
		}
		return (
			<div>
				<h2>{this.props.user}</h2>
			</div>
		);
	}
}

function mapStateToProps(state) {
	console.log('mapStateToProps ', state)
	return {
		user: state.active.activeUser
	};
}

export default connect(mapStateToProps)(UserDetail);