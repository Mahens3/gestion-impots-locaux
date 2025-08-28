import { Outlet } from 'react-router-dom'
import Layout from './components/layout/layout'
import { ToastContainer } from 'react-toastify'

const Main = () => {
  return (
    <Layout>
      <ToastContainer position='top-right'/>
      <Outlet />
    </Layout>
  )
}

export default Main