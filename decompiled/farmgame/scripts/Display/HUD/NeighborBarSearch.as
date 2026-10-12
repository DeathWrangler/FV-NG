package Display.HUD
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class NeighborBarSearch extends Sprite
   {
      
      private static const ASSET_SWF_URL:String = "assets/hud/FV_SearchBar.swf";
      
      private var m_searchBar:MovieClip = null;
      
      private var m_searchField:TextField = null;
      
      private var m_clearButton:MovieClip = null;
      
      public function NeighborBarSearch()
      {
         super();
         LoadingManager.load(Global.getAssetURL(ASSET_SWF_URL),this.onAssetLoaded);
         Global.stage.addEventListener(Event.FULLSCREEN,this.onFullscreen);
      }
      
      private function onAssetLoaded(event:Event) : void
      {
         var searchAsset:MovieClip = null;
         var assetLoader:Loader = event.target.loader as Loader;
         if(assetLoader != null)
         {
            searchAsset = assetLoader.content as MovieClip;
            addChild(searchAsset);
            addEventListener(FocusEvent.FOCUS_IN,this.disableShortcut);
            addEventListener(FocusEvent.FOCUS_OUT,this.enableShortcut);
            this.m_searchBar = searchAsset.searchBar_mc;
            this.m_searchField = this.m_searchBar.searchField_tf;
            this.m_searchField.addEventListener(Event.CHANGE,this.keyboardEventHandler);
            this.m_clearButton = this.m_searchBar.clearsearch_bt;
            this.m_clearButton.buttonMode = true;
            this.m_clearButton.addEventListener(MouseEvent.MOUSE_UP,this.onClearClick);
            this.m_clearButton.addEventListener(MouseEvent.MOUSE_DOWN,this.onClearDown);
            this.m_clearButton.addEventListener(MouseEvent.ROLL_OVER,this.onClearOver);
            this.m_clearButton.addEventListener(MouseEvent.ROLL_OUT,this.onClearOut);
         }
      }
      
      private function onFullscreen(event:Event) : void
      {
         this.visible = !Utilities.isFullScreen();
      }
      
      private function disableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = true;
         if(this.m_searchField.text == ZLocUtils.t("Dialogs","Search"))
         {
            this.m_searchField.text = "";
            this.m_searchBar.search_mc.visible = false;
         }
      }
      
      private function enableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = false;
         if(this.m_searchField.text == "")
         {
            this.m_searchField.text = ZLocUtils.t("Dialogs","Search");
            this.m_searchBar.search_mc.visible = true;
         }
      }
      
      private function onClearClick(event:MouseEvent) : void
      {
         this.m_searchField.text = "";
         this.m_searchField.stage.focus = this.m_searchField;
         this.m_searchField.setSelection(0,0);
         this.m_clearButton.gotoAndStop(1);
         Global.ui.m_friendBar.filterFriendsByString();
      }
      
      private function onClearOver(event:MouseEvent) : void
      {
         this.m_clearButton.gotoAndStop(2);
      }
      
      private function onClearOut(event:MouseEvent) : void
      {
         this.m_clearButton.gotoAndStop(1);
      }
      
      private function onClearDown(event:MouseEvent) : void
      {
         this.m_clearButton.gotoAndStop(3);
      }
      
      private function keyboardEventHandler(event:Event) : void
      {
         Global.ui.m_friendBar.filterFriendsByString(this.m_searchField.text);
      }
   }
}

