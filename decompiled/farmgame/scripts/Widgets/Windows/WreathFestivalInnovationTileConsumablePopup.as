package Widgets.Windows
{
   import Managers.WreathFestivalInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class WreathFestivalInnovationTileConsumablePopup extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private var m_title_tf:TextField;
      
      private var m_brief_tf:TextField;
      
      private const TILE_UNLOCK_CONSUMABLE_COUNT:int = 50;
      
      public function WreathFestivalInnovationTileConsumablePopup(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var count:int = this.manager.getTileUnlockCount();
         if(m_window.hasOwnProperty("newrewardtitle_tf"))
         {
            this.m_title_tf = TextField(m_window["newrewardtitle_tf"]);
            this.m_title_tf.text = "UNLOCKER OF TILES!";
            this.m_title_tf.visible = true;
         }
         if(m_window.hasOwnProperty("cutterscount_tf"))
         {
            this.m_brief_tf = TextField(m_window["cutterscount_tf"]);
            this.m_brief_tf.text = "You have got " + (count * this.TILE_UNLOCK_CONSUMABLE_COUNT).toString() + " Flower Cutters on unlocking " + count.toString() + " tiles. Enjoy!";
            this.m_brief_tf.visible = true;
         }
         if(m_window.hasOwnProperty("ok_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["ok_bt"],"Great!",this.onAcceptClick));
         }
         if(m_window.hasOwnProperty("npc"))
         {
            (m_window["npc"] as MovieClip).visible = true;
         }
      }
      
      public function onAcceptClick(e:Event = null) : void
      {
         this.manager.addTileUnlockCount();
         this.close();
      }
      
      private function get manager() : WreathFestivalInnovationManager
      {
         return WreathFestivalInnovationManager.getInstance();
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.enableInput = true;
            this.manager.mainWindow.untintWindow();
         }
         super.close();
      }
   }
}

