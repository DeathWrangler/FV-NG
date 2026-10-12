package Widgets.Windows.MOTD
{
   import Classes.util.MovieClipUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class BoraboraInnovationPremarketingWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public static const SERVICE_CLASS:String = "BoraboraInnovationPremarketingService";
      
      public static const SEEN_FLAG:String = "BoraboraInnovationPremarketingGrantFlag";
      
      private static const ITEM_NAME:String = "consume_instagrow";
      
      private static const ITEM_QTY:int = 2;
      
      private var m_title_tf:ZwTextField;
      
      private var m_sizeMc:ZwWidget;
      
      public function BoraboraInnovationPremarketingWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var mainWindow:MovieClip = null;
         var speechbuble:MovieClip = null;
         var speechbubleTf:ZwTextField = null;
         var body2_tf:ZwTextField = null;
         var body_tf:ZwTextField = null;
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["title_tf"])
            {
               this.m_title_tf = addWidget(new ZwTextField(m_window.mainWindow["title_tf"],"Tropical Ever After!")) as ZwTextField;
               this.m_title_tf.visible = true;
            }
            if(m_window.hasOwnProperty("mainWindow"))
            {
               mainWindow = m_window["mainWindow"] as MovieClip;
               if(mainWindow.hasOwnProperty("speechbuble_mc"))
               {
                  speechbuble = mainWindow["speechbuble_mc"] as MovieClip;
                  speechbuble.visible = true;
                  if(speechbuble.hasOwnProperty("speechbuble_tf"))
                  {
                     speechbubleTf = addWidget(new ZwTextField(speechbuble["speechbuble_tf"],"Welcome to Bora Bora & Tropical Ever After! \n Ready for your new job?")) as ZwTextField;
                     speechbubleTf.visible = true;
                  }
               }
               if(mainWindow.hasOwnProperty("body2_tf"))
               {
                  body2_tf = addWidget(new ZwTextField(mainWindow["body2_tf"],"")) as ZwTextField;
                  body2_tf.visible = false;
               }
               if(mainWindow.hasOwnProperty("body_tf"))
               {
                  body_tf = addWidget(new ZwTextField(mainWindow["body_tf"],"")) as ZwTextField;
                  body_tf.visible = false;
               }
            }
            FarmStatsManager.count("MOTD","impressions","MOTD_BORABORA_INNOVATION_PREMARKETING");
            if(m_window.mainWindow["accept_bt"])
            {
               m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Let\'s do this!",this.onAccept)) as FarmAnimatedTextButton;
               m_accept_bt.visible = true;
            }
         }
         if(m_window.hasOwnProperty("size_mc"))
         {
            this.m_sizeMc = addWidget(new ZwWidget(m_window.size_mc),true) as ZwWidget;
         }
      }
      
      private function onGrantReward(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag(SEEN_FLAG);
         }
      }
      
      private function grantReward() : void
      {
         if(Global.player.getSeenFlag(SEEN_FLAG))
         {
            super.close();
         }
         else
         {
            Global.player.addGift(ITEM_NAME,"0",ITEM_QTY);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantReward",this.onGrantReward));
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         this.grantReward();
         super.onAccept(event);
      }
   }
}

