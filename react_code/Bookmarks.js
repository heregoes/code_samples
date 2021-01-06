import React, { Component } from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { addBookmark, removeBookmark, getBookmarks } from '../../actions/bookmarkActions'
import Bookmark from './bookmark/Bookmark'

class Bookmarks extends Component {

    static propTypes = {
        isAuthenticated: PropTypes.bool,
    };

    async componentDidMount() {
        this.props.auth.user ? await this.props.getBookmarks(this.props.auth.user._id): console.log('no auth')
    }

    onRemoveBookmark = id => {
        this.props.removeBookmark(id)
    }

    async componentDidUpdate() {
        // this.props.auth.user ? await this.props.getBookmarks(this.props.auth.user._id): console.log('no auth')
    }

    render() {
        const { bookmarks } = this.props.bookmarks
        let body = []

        if (bookmarks.length !== 0) {
            bookmarks.map( (bookmark, i) => {
                body.push(
                    <div className="col-md-6" key={i}>
                        <Bookmark bookmark={bookmark}/>
                    </div>    
                )
            })
        } else {
            body.push(
                <div className="col-md-6">
                    <h3>No Saved Bookmarks</h3>
                </div>
            )
        }

        return (

            <div className="mt-3">
                <h2>bookmarks</h2>
                <div className="row mt-5 mb-4">
                    {body}
                </div>
                    
            </div>
        )
    }
}



const mapStateToProps = state => ({
    bookmarks: state.bookmarks,
    games: state.games,
    auth: state.auth,
    isAuthenticated: state.auth.isAuthenticated
});


export default connect(
    mapStateToProps,
    { addBookmark, removeBookmark, getBookmarks}
  )(Bookmarks);