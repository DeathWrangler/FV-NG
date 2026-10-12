package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.CommunityMatchmakingUtility;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class HalloweenInnovationAddNeighborWindow extends FarmWindow
   {
      
      protected var m_featureName:String = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_profile_mc:MovieClip;
      
      private var m_player1_icon:FarmIcon;
      
      private var m_neighborId:String;
      
      public function HalloweenInnovationAddNeighborWindow(dialogAsset:String, featureName:String, neighborId:String = "", buttonCallback:Function = null)
      {
         super(dialogAsset);
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_neighborId = neighborId;
      }
      
      override protected function postLoadComplete() : void
      {
         var profileIconUrl:String = null;
         super.postLoadComplete();
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_AddNeighborTitle"))) as ZwTextField;
            }
            if(m_window.hasOwnProperty("generic_tf"))
            {
               addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_AddNeighborSubText")));
            }
            if(m_window.hasOwnProperty("yes_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window["yes_bt"],"Yes",this.onAcceptAddNeighbor));
            }
            if(m_window.hasOwnProperty("no_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window["no_bt"],"No",this.onRejectAddNeighbor));
            }
            if(m_window.hasOwnProperty("profile1_mc"))
            {
               this.m_profile_mc = m_window["profile1_mc"] as MovieClip;
               if(this.m_profile_mc)
               {
                  this.m_profile_mc.visible = true;
                  this.m_player1_icon = new FarmIcon(this.m_profile_mc["icon_mc"]);
                  this.m_player1_icon.setIconSize(100,100);
                  this.m_player1_icon.setSmoothing(true);
                  profileIconUrl = Global.getFBPicUrl(this.m_neighborId);
                  this.m_player1_icon.loadIcon(profileIconUrl);
               }
            }
         }
      }
      
      public function onAcceptAddNeighbor(event:Event) : void
      {
         FarmStatsManager.count("RockPaperShivers","AddNeighbour_window","close","accept");
         var maxNeighbors:int = Global.farmGameSettingsManager.getInt(CommunityMatchmakingUtility.MAX_NEIGHBORS_CONFIG_KEY,CommunityMatchmakingUtility.MAX_NUM_NEIGHBORS);
         maxNeighbors = CommunityMatchmakingUtility.getDebugMaxNeighborLimit(maxNeighbors);
         if(Global.friendManager.neighborUids.length >= maxNeighbors)
         {
            FarmStatsManager.count("RockPaperShivers","AddNeighbour_window","close","max_limit_reached");
            UI.displayCustomMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_NeighborListfullText"));
         }
         else
         {
            TransactionManager.addTransaction(new TGenericTransaction("HalloweenUSAInnovationService","sendNeighborRequest",null,[this.m_featureName,this.m_neighborId]));
         }
         this.close();
      }
      
      public function onRejectAddNeighbor(event:Event) : void
      {
         FarmStatsManager.count("RockPaperShivers","AddNeighbour_window","close","reject");
         this.close();
      }
      
      override public function close() : void
      {
         if(this.m_callback != null)
         {
            this.m_callback();
         }
         super.close();
      }
   }
}

