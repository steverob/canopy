/*   Copyright (c) 2010-2011, Evergreen Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("List", function() {
  describe("runDelayedSearch", function() {
    beforeEach( function(){
      spec.loadFixture('empty_people_search');
      List.initialize();
    });

    it('inserts contact html', function(){
      List.handleSearchRefresh( { count:1, search_html: "<div class='testing_insert_div'>hello</div>" } );
      expect($(".testing_insert_div").text()).toEqual("hello");
    });
  });
});
