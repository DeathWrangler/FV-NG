package Widgets.Windows
{
   import Cache.Classes.ZCacheUtil;
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.events.Event;
   
   public class FaceOffShareReward extends FarmWindow
   {
      
      public static const DEFAULT_TRANSACTION_SERVICE:String = "FaceOffService";
      
      private var m_item:FarmItem;
      
      private var m_shareNews:Boolean;
      
      private var m_callback:Function;
      
      public function FaceOffShareReward(dialogAssetUrl:String, itemName:String, callback:Function = null)
      {
         super(dialogAssetUrl);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         }
         else
         {
            this.m_item = new FarmItem(Global.farmGameSettingsManager.getItemXMLByName(itemName));
         }
         this.m_shareNews = true;
         this.m_callback = callback;
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window["title_tf"])
         {
            addWidget(new ZwTextField(m_window.title_tf,"Congrats!"));
         }
         if(Boolean(m_window["item_tf"]) && Boolean(this.m_item))
         {
            addWidget(new ZwTextField(m_window.item_tf,"You won a " + ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName)));
         }
         if(m_window["info_tf"])
         {
            addWidget(new ZwTextField(m_window.info_tf,"Find it in your giftbox!"));
         }
         if(m_window["checkbox_tf"])
         {
            addWidget(new ZwTextField(m_window.checkbox_tf,"Share the good news!"));
         }
         if(m_window["back_mc"])
         {
            addWidget(new ZwBaseWidget(m_window.back_mc));
         }
         if(Boolean(m_window["icon_mc"]) && Boolean(this.m_item))
         {
            addWidget(new ObjectPreviewFrame(m_window.icon_mc,this.m_item));
         }
         if(m_window["checkMark_mc"])
         {
            addWidget(new ZwButton(m_window.checkMark_mc,this.checkboxClicked));
         }
         if(m_window["checkBox_mc"])
         {
            addWidget(new ZwButton(m_window.checkBox_mc,this.checkboxClicked));
         }
         if(m_window["accept_bt"])
         {
            addWidget(new FarmAnimatedButton(m_window.accept_bt,this.acceptButtonClicked));
         }
      }
      
      private function checkboxClicked(event:Event) : void
      {
         if(this.m_shareNews)
         {
            getWidget(m_window.checkMark_mc).visible = false;
            this.m_shareNews = false;
         }
         else
         {
            getWidget(m_window.checkMark_mc).visible = true;
            this.m_shareNews = true;
         }
      }
      
      private function acceptButtonClicked(event:Event) : void
      {
         if(this.m_shareNews)
         {
            TransactionManager.addTransaction(new TGenericTransaction(DEFAULT_TRANSACTION_SERVICE,"rewardShareFeed",this.shareTransactionComplete,[this.m_item.name]));
         }
         if(this.m_callback != null)
         {
            this.m_callback();
         }
         close();
      }
      
      private function shareTransactionComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,ZCacheUtil.applyPartial(this.shareFeedTransactionComplete,this,[result]));
         }
      }
      
      private function shareFeedTransactionComplete(result:Object, success:Boolean) : void
      {
      }
   }
}

