package Widgets.Frames
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class SearchFrame extends ZwFrame
   {
      
      private var m_defaultString:String = ZLocUtils.t("Dialogs","Search");
      
      private var m_searchField:ZwTextField = null;
      
      private var m_clearSearchButton:FarmAnimatedButton = null;
      
      private var m_searchString:String = "";
      
      private var m_searchIcon:ZwWidget = null;
      
      private var m_updateCallback:Function = null;
      
      public function SearchFrame(element:DisplayObject, updateCallback:Function = null, searchText:String = "")
      {
         super(element);
         this.m_updateCallback = updateCallback;
         this.m_searchField = addWidget(new ZwTextField(this.element.searchField_tf,this.m_defaultString)) as ZwTextField;
         if(searchText != "")
         {
            this.m_searchField.text = searchText;
         }
         this.m_searchField.restrict("0-9 a-zA-Z\\-\'");
         this.element.searchField_tf.addEventListener(FocusEvent.FOCUS_OUT,this.enableShortcut);
         this.element.searchField_tf.addEventListener(FocusEvent.FOCUS_IN,this.disableShortcut);
         this.element.searchField_tf.addEventListener(MouseEvent.CLICK,this.onSearchTextFieldClick);
         this.element.searchField_tf.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUpHandler);
         this.m_clearSearchButton = addWidget(new FarmAnimatedButton(this.element.clearsearch_bt,this.onClearSearch)) as FarmAnimatedButton;
         this.m_searchIcon = addWidget(new ZwWidget(this.element.search_mc)) as ZwWidget;
         this.update();
      }
      
      public function update() : void
      {
         this.visible = true;
         this.m_searchField.visible = true;
         var clearedSearch:Boolean = this.m_searchField.text == "" || this.m_searchField.text == this.m_defaultString;
         this.m_clearSearchButton.visible = !clearedSearch;
         this.m_searchIcon.visible = clearedSearch;
         var searchString:String = "";
         if(!clearedSearch)
         {
            searchString = this.m_searchField.text.toLowerCase();
         }
         if(this.m_updateCallback != null && searchString != this.m_searchString)
         {
            this.m_searchString = searchString;
            this.m_updateCallback(this.m_searchString);
         }
      }
      
      private function enableShortcut(event:FocusEvent) : void
      {
         Global.enableDebugKeys = true;
      }
      
      private function disableShortcut(event:FocusEvent) : void
      {
         Global.enableDebugKeys = false;
      }
      
      private function onSearchTextFieldClick(event:MouseEvent) : void
      {
         Global.farmGame.switchOutFullScreen();
         if(this.m_searchField.text == this.m_defaultString)
         {
            this.m_searchField.text = "";
         }
         this.update();
      }
      
      private function onKeyUpHandler(event:KeyboardEvent) : void
      {
         this.update();
      }
      
      private function onClearSearch(event:MouseEvent) : void
      {
         this.m_searchField.text = this.m_defaultString;
         this.update();
      }
      
      public function reset() : void
      {
         this.m_searchField.text = this.m_defaultString;
         this.update();
      }
   }
}

