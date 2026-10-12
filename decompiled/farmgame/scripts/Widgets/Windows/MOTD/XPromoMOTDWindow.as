package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.events.MouseEvent;
   
   public class XPromoMOTDWindow extends CustomWindowMOTDBase
   {
      
      private var playUrl:String = "";
      
      private var target:String = "_blank";
      
      private var gameId:String = "";
      
      private var assetUrl:String = "";
      
      private var buttonTextKey:String = "";
      
      public const SHOW_CLOSE_BUTTON_VARIANT:int = 3;
      
      public function XPromoMOTDWindow(params:Object)
      {
         this.assetUrl = params["dialog"];
         this.playUrl = params["crossPromoPlayUrl"];
         this.gameId = params["crossPromoGameId"];
         this.buttonTextKey = params["buttonText"];
         if(params["openInSameWindow"] != undefined && params["openInSameWindow"] == "true")
         {
            this.target = "_top";
         }
         super(this.assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var button:FarmAnimatedTextButton = null;
         super.postLoadComplete();
         var buttonText:String = ZLocUtils.t(this.buttonTextKey.split(":")[0],this.buttonTextKey.split(":")[1]);
         if(m_window.accept_bt)
         {
            button = addWidget(new FarmAnimatedTextButton(m_window.accept_bt,buttonText,this.onClickPlay)) as FarmAnimatedTextButton;
            button.visible = true;
         }
      }
      
      override public function show() : void
      {
         var showClose:Boolean = false;
         if(m_isLoaded)
         {
            showClose = false;
            if(Global.experimentManager.getExperimentVariant("fv_coasterville_incentivized_xpromo_ui") == this.SHOW_CLOSE_BUTTON_VARIANT)
            {
               showClose = true;
            }
            if(!showClose && Boolean(m_closeButton))
            {
               m_closeButton.visible = false;
            }
         }
         super.show();
      }
      
      private function onClickPlay(event:MouseEvent) : void
      {
         FarmStatsManager.count("dialog","xpromo","click",this.gameId,"launch_xpromo_from_farm_to_" + this.gameId);
         GlobalEngine.socialNetwork.redirect(this.playUrl,null,this.target,false);
         super.onClose(event);
      }
   }
}

