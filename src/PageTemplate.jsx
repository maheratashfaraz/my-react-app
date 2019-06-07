import React, { Component } from 'react';
import {createStore} from 'redux';
import allReducers from './reducers';
import {Provider} from 'react-redux';
import App from './components/app';

export class PageTemplate extends Component {
  render() {
  	const store = createStore(allReducers);
    return (
      <div>
        <Provider store={store}>
        	<App/>
        </Provider>
      </div>
    );
  }
}
export default PageTemplate;
