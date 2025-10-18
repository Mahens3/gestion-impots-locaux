import { useEffect, useState } from 'react'
import { styled } from '@mui/material/styles'
import SideNav from './side-nav'
import TopNav from './top-nav'
// import { useNavigate } from 'react-router-dom'
import getToken from 'presentation/helpers/token'

const SIDE_NAV_WIDTH = 280

const LayoutRoot = styled('div')(({ theme }) => ({
  display: 'flex',
  flex: '1 1 auto',
  maxWidth: '100%',
  [theme.breakpoints.up('lg')]: {
    paddingLeft: SIDE_NAV_WIDTH
  }
}))

const LayoutContainer = styled('div')({
  display: 'flex',
  flex: '1 1 auto',
  flexDirection: 'column',
  width: '100%'
})

const Layout = (props) => {
  const { children } = props
  const [openNav, setOpenNav] = useState(false)

  // const navigate = useNavigate()

  const checkAuthentification = () => {
    const token = getToken()

    if (token === null) {
      //navigate("/")
    }
  }

  useEffect(() => {
    checkAuthentification()
  }, [])

  return (
    <>
      {
        (props.printed === false || props.printed === undefined) &&
        <>
          <TopNav onNavOpen={() => setOpenNav(true)} />
          <SideNav onClose={() => setOpenNav(false)} open={openNav} />
        </>
      }
      <LayoutRoot>
        <LayoutContainer>{children}</LayoutContainer>
      </LayoutRoot>
    </>
  )
}

export default Layout
