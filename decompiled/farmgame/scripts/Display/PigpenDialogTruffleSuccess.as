package Display
{
   import Engine.Managers.LoadingManager;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class PigpenDialogTruffleSuccess extends GenericPopupTitleSimple
   {
      
      private var m_userIconMC:MovieClip = new MovieClip();
      
      private var m_truffleIconMC:MovieClip = new MovieClip();
      
      public function PigpenDialogTruffleSuccess(message:String, sTitleToken:String = "SetTitle", sUserIconUrl:String = "", sTruffleIconRelUrl:String = "", type:int = 4, closeCallback:Function = null, dialogAsset:String = "assets/dialogs/FV_PigPen_Congrats.swf", rewardUrl:String = "", useHtmlText:Boolean = false, bAddClickBlocker:Boolean = true)
      {
         super(message,sTitleToken,type,closeCallback,dialogAsset,rewardUrl,useHtmlText,bAddClickBlocker);
         this.loadAndAttachImage(sUserIconUrl,this.m_userIconMC);
         if(sTruffleIconRelUrl)
         {
            this.loadAndAttachImage(sTruffleIconRelUrl,this.m_truffleIconMC);
         }
      }
      
      private function loadAndAttachImage(sImageUrl:String, pParentMC:MovieClip) : void
      {
         var icon:Loader = null;
         if(sImageUrl != null && sImageUrl != "")
         {
            icon = LoadingManager.load(sImageUrl,function(event:Event):void
            {
               var dispObj:* = undefined;
               if(Boolean(icon) && Boolean(icon.content))
               {
                  dispObj = icon.content;
                  dispObj.scaleX = 1;
                  dispObj.scaleY = 1;
                  pParentMC.addChildAt(dispObj,0);
               }
            });
         }
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         if(m_window.popupBox_mc.userIcon_mc)
         {
            m_window.popupBox_mc.userIcon_mc.addChild(this.m_userIconMC);
         }
         if(m_window.popupBox_mc.icon_mc)
         {
            m_window.popupBox_mc.icon_mc.addChild(this.m_truffleIconMC);
         }
      }
   }
}

