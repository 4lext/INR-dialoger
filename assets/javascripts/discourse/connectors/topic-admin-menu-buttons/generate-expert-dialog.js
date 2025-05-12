export default {
  shouldRender(args, component) {
    const { currentUser } = component;
    const { topic } = args.model;
    
    return currentUser && currentUser.staff && topic && topic.details;
  }
}; 