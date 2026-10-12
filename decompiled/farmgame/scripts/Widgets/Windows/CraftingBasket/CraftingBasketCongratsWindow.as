package Widgets.Windows.CraftingBasket
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.*;
   import flash.events.Event;
   
   public class CraftingBasketCongratsWindow extends GenericSingleRewardPopup
   {
      
      protected var m_bonusItemName:String = null;
      
      private var m_bonusText:String = null;
      
      private var m_prizeFrame:ZwFrame;
      
      private var m_bonusIcon:FarmIcon;
      
      private var m_callback:Function = null;
      
      private var m_params:Object;
      
      protected var m_objectPreviewFrame:ObjectPreviewFrame;
      
      private var m_iconPreview:FarmIcon;
      
      public function CraftingBasketCongratsWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem, callback:Function = null, params:Object = null, bonusItemName:String = null, bonusText:String = null)
      {
         this.m_bonusItemName = bonusItemName;
         this.m_bonusText = bonusText;
         this.m_callback = callback;
         this.m_params = params;
         super(dialogAsset,featureName,rewardItem,this.buttonCallback);
      }
      
      override protected function postLoadComplete() : void
      {
         var prizeItem:FarmItem = null;
         m_zoomingScale = 2;
         super.postLoadComplete();
         if(this.m_bonusItemName != null)
         {
            this.m_prizeFrame = addWidget(new ZwFrame(m_window.prize_mc)) as ZwFrame;
            prizeItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_bonusItemName);
            if(m_window.prize_mc.name_tf)
            {
               this.m_prizeFrame.addWidget(new ZwTextField(m_window.prize_mc.name_tf,ZLocUtils.tk_pk_asTitle(prizeItem.friendlyName)));
            }
            if(prizeItem.type == "change_farm")
            {
               this.m_iconPreview = new FarmIcon(m_window.prize_mc.icon_mc,prizeItem.iconUrl);
               this.m_iconPreview.setIconSize(FarmIcon.STANDARD_ICON_WIDTH,FarmIcon.STANDARD_ICON_HEIGHT);
               addWidget(this.m_iconPreview,true);
            }
            else
            {
               this.m_objectPreviewFrame = new ObjectPreviewFrame(m_window.prize_mc.icon_mc,prizeItem,null,null,[100]);
               addWidget(this.m_objectPreviewFrame,true);
            }
         }
         if(Boolean(this.m_bonusText) && m_window.hasOwnProperty("generic2_tf"))
         {
            (getWidget(m_window["generic2_tf"]) as ZwTextField).text = this.m_bonusText;
         }
      }
      
      override protected function release() : void
      {
         this.m_prizeFrame = null;
         if(this.m_bonusIcon)
         {
            this.m_bonusIcon = null;
         }
         if(this.m_objectPreviewFrame)
         {
            this.m_objectPreviewFrame = null;
         }
         super.release();
      }
      
      private function buttonCallback(event:Event) : void
      {
         this.m_callback(this.m_params,this);
      }
   }
}

