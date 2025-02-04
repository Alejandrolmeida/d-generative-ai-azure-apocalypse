import { FC, Fragment } from 'react';
import { Provider } from 'react-redux';
import Header from './layoutcomponent/header';
// import Sidebar from './layoutcomponent/sidebar';
import { Outlet } from 'react-router-dom';
// import Footer from './layoutcomponent/footer';
// import TabToTop from './layoutcomponent/tabtotop';
import store from '../common/redux/store';
import { Helmet, HelmetProvider } from 'react-helmet-async';

interface ComponentProps { }

const App: FC<ComponentProps> = () => {
  return (
    <Fragment>
      <Provider store={store}>
      <HelmetProvider>
          <Helmet
            htmlAttributes={{
              lang: "en",
              dir: "ltr",
              "data-nav-layout": "horizontal",
              "data-theme-mode": "light",
              "data-header-styles": "light",
              "data-menu-styles": "light",
              "data-vertical-style": "overlay",
            }}
          >
            <body className=''></body>
          </Helmet>
        </HelmetProvider> 
        <div className="page">
          <Header />
          {/* <Sidebar /> */}
          <div className="main-content app-content">
            <div className="main-container container-fluid">
              <Outlet />
            </div>
          </div>
        {/* <Footer /> */}
        </div>
        {/* <TabToTop /> */}
      </Provider>
    </Fragment>
  );
};

export default App;