package Widgets.Windows
{
   import Engine.Managers.StatsManager;
   import Managers.OrderBoard.TropicalMarketInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class TropicalMarketInnovationTileRewardsWindow extends FarmWindowWithTutorial
   {
      
      private static const FEATURE_NAME:String = "TropicalMarketInnovation";
      
      private static const NO_OF_LEVELS:int = 5;
      
      private var m_featureName:String;
      
      private var m_size_mc:MovieClip;
      
      private var m_title_tf:ZwTextField;
      
      private var m_subtext_tf:ZwTextField;
      
      private var m_okay_bt:FarmAnimatedTextButton;
      
      private var m_gift_slabs_frame_mc:MovieClip;
      
      private var m_gift_slabs_mc:Array = [];
      
      public function TropicalMarketInnovationTileRewardsWindow(featureName:String = "TropicalMarketInnovation", assetUrl:String = null)
      {
         this.m_featureName = featureName;
         super(featureName,assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         var m_gift_slab_mc:MovieClip = null;
         if(m_window)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               addWidget(this.m_title_tf = new ZwTextField(m_window["title_tf"],"Tropical Market"));
               this.m_title_tf.visible = true;
            }
            if(m_window.hasOwnProperty("subtext_tf"))
            {
               addWidget(this.m_subtext_tf = new ZwTextField(m_window["subtext_tf"],"More Escape Tokens = More Land!"));
               this.m_subtext_tf.visible = true;
            }
            if(m_window.hasOwnProperty("size_mc"))
            {
               this.m_size_mc = m_window["size_mc"] as MovieClip;
               this.m_size_mc.visible = true;
            }
            if(m_window.hasOwnProperty("okay_bt"))
            {
               this.m_okay_bt = new FarmAnimatedTextButton(m_window["okay_bt"],"Okay",this.onOkayButtonClick);
               this.m_okay_bt.visible = true;
            }
            if(m_window.hasOwnProperty("gift_slab_all_mc"))
            {
               this.m_gift_slabs_frame_mc = m_window["gift_slab_all_mc"] as MovieClip;
               this.m_gift_slabs_frame_mc.visible = true;
               for(i = 0; i < NO_OF_LEVELS; i++)
               {
                  if(this.m_gift_slabs_frame_mc.hasOwnProperty("gift_slab_" + String(i) + "_mc"))
                  {
                     m_gift_slab_mc = this.m_gift_slabs_frame_mc["gift_slab_" + String(i) + "_mc"] as MovieClip;
                  }
                  this.m_gift_slabs_mc.push(m_gift_slab_mc);
                  if(this.m_gift_slabs_mc[i])
                  {
                     this.m_gift_slabs_mc[i].visible = true;
                  }
               }
            }
            if(this.manager.mainWindow)
            {
               this.manager.mainWindow.tintWindow();
               this.manager.mainWindow.enableInput = false;
            }
         }
      }
      
      private function onOkayButtonClick(event:MouseEvent) : void
      {
         StatsManager.count(this.m_featureName,"LandReward_Dialog","okay");
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.onClose(event);
      }
      
      private function get manager() : TropicalMarketInnovationManager
      {
         return TropicalMarketInnovationManager.getInstance(this.m_featureName);
      }
      
      override protected function onClose(event:Event) : void
      {
         StatsManager.count(this.m_featureName,"LandReward_Dialog","close");
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.onClose(event);
      }
   }
}

