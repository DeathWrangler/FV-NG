package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.CraftingBasket.CraftingBasketCongratsWindow;
   import flash.display.MovieClip;
   
   public class EnableSpecificMovieClipRewardWindow extends CraftingBasketCongratsWindow
   {
      
      private var m_movieClipName:String = null;
      
      private var m_releaseCallback:Function = null;
      
      private var m_params2:Object;
      
      private var m_callback:Function = null;
      
      private var m_rewardItem:FarmItem = null;
      
      protected var m_bonusTitle:String = null;
      
      public function EnableSpecificMovieClipRewardWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem, movieClipName:String = null, callback:Function = null, releaseCallback:Function = null, params:Object = null, bonusItemName:String = null, bonusText:String = null, bonusTitle:String = null)
      {
         this.m_movieClipName = movieClipName;
         this.m_releaseCallback = releaseCallback;
         this.m_callback = callback;
         this.m_params2 = params;
         this.m_rewardItem = rewardItem;
         this.m_bonusTitle = bonusTitle;
         super(dialogAsset,featureName,rewardItem,callback,params,bonusItemName,bonusText);
      }
      
      override protected function postLoadComplete() : void
      {
         var prizeItem:FarmItem = null;
         super.postLoadComplete();
         if(m_window[this.m_movieClipName])
         {
            m_window[this.m_movieClipName].visible = true;
            (m_window[this.m_movieClipName] as MovieClip).play();
         }
         if(m_window.vs_0_mc)
         {
            m_window.vs_0_mc.visible = true;
            (m_window.vs_0_mc as MovieClip).play();
         }
         if(m_window.animation_mc)
         {
            m_window.animation_mc.visible = true;
            (m_window.animation_mc as MovieClip).play();
         }
         if(m_bonusItemName != null)
         {
            prizeItem = Global.farmGameSettingsManager.getFarmItemByName(m_bonusItemName);
            if(prizeItem.type != "change_farm")
            {
               if(m_window.prize_mc.icon_mc_1)
               {
                  m_objectPreviewFrame = getWidget(m_window.prize_mc.icon_mc) as ObjectPreviewFrame;
                  if(m_objectPreviewFrame)
                  {
                     removeWidget(m_objectPreviewFrame);
                     m_objectPreviewFrame = null;
                  }
                  m_objectPreviewFrame = new ObjectPreviewFrame(m_window.prize_mc.icon_mc_1,prizeItem,null,[prizeItem.sizeX == 1 ? 2 : 1.75]);
                  addWidget(m_objectPreviewFrame,true);
               }
            }
         }
         if(this.m_rewardItem == null && Boolean(m_window.prize_mc))
         {
            m_window.prize_mc.visible = false;
         }
         if(Boolean(title_tf) && Boolean(this.m_bonusTitle))
         {
            title_tf.text = this.m_bonusTitle;
         }
      }
      
      override protected function release() : void
      {
         this.m_movieClipName = null;
         super.release();
         this.m_releaseCallback(this.m_params2);
      }
   }
}

