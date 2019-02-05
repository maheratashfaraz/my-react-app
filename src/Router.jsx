import React from 'react';
import { Switch, Router, Route, Redirect } from 'react-router';
import createHistory from 'history/createBrowserHistory';

import { PageTemplate } from './PageTemplate';

export const history = createHistory();

export default () => (
  <Router history={history}>
    <Switch>
      <Route
        exact
        path="/home"
        render={routeProps => <PageTemplate {...routeProps} />}
      />
      <Route exact path="/" render={() => <Redirect to="/home" />} />
    </Switch>
  </Router>
);
