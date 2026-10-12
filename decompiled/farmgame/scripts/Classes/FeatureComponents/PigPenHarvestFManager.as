package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.PigpenDialogTruffleSuccess;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.IconTitleToasterWindow;
   
   public class PigPenHarvestFManager extends HarvestFManager implements IHarvestComponent
   {
      
      private var m_lastTruffleResult:Object;
      
      public function PigPenHarvestFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var postReward:Object = result.postHarvestData;
         var pigData:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(postReward.pigCode);
         var prizeData:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(postReward.truffleFound);
         if(postReward != null && postReward.hasOwnProperty("truffleFound") && postReward.truffleFound != "" && prizeData != null && pigData != null && postReward.friendName != null)
         {
            this.m_lastTruffleResult = postReward;
            this.m_lastTruffleResult["imageUrl"] = prizeData.getImageByName("feedIcon");
            this.m_lastTruffleResult["truffleName"] = prizeData.friendlyName;
            this.openDialogHuntSuccessFoundTruffle(postReward.friendPic,postReward.friendName,pigData.friendlyName,prizeData.friendlyName,prizeData.getImageByName("icon"));
         }
         else if(Global.experimentManager.getExperimentVariant("fv_deprecateTruffles") < 1)
         {
            this.openDialogHuntFoundNothing();
         }
      }
      
      private function openDialogHuntSuccessFoundTruffle(sUserImageUrl:String, sFriendName:String, sPigType:String, sTruffleType:String, sTruffleImageRelUrl:String) : void
      {
         var sMsg:String = ZLocUtils.t("Dialogs","PigpenBuilding_Hunt_SuccessFoundTruffle_Body",{
            "itemA":ZLocUtils.tk_pk(sPigType),
            "user":ZLocUtils.tn(sFriendName),
            "itemB":ZLocUtils.tk_pk(sTruffleType),
            "user_same":sFriendName
         });
         var sTitleToken:String = "PigpenBuilding_Hunt_SuccessFoundTruffle_Title";
         var tmpPopup:PigpenDialogTruffleSuccess = new PigpenDialogTruffleSuccess(sMsg,sTitleToken,sUserImageUrl,sTruffleImageRelUrl,GenericPopup.TYPE_SHARECANCEL,this.onHuntFoundTruffleClose);
         tmpPopup.setTrackerKey("pigpen_found_truffle");
         UI.displayPopup(tmpPopup,false,"Hunt_SuccessFoundTruffle",true);
      }
      
      private function openDialogHuntFoundNothing() : void
      {
         var title:String = ZLocUtils.t("Dialogs","PigpenBuilding_Hunt_FoundNothing_Title");
         var body:String = ZLocUtils.t("Dialogs","PigpenBuilding_Hunt_FoundNothingv2_Body");
         var icon:String = Global.farmGameSettingsManager.getFarmItemByName("pigpenv2_finished").icon;
         ToasterManager.getInstance().add(new IconTitleToasterWindow(title,body,icon,TOAST_ASSET,TOAST_ASSET_SCALEFACTOR));
         FarmStatsManager.count("pigpenv2","huntActive","getNothing");
      }
      
      private function onHuntFoundTruffleClose(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("pigpenv2","huntActive","getTruffle","clickShare");
            bundleData = {
               "reward_link":this.m_lastTruffleResult.rewardUrl,
               "friendName":this.m_lastTruffleResult.friendName,
               "truffleType":this.m_lastTruffleResult.truffleName,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_lastTruffleResult.rewardUrl,
                  "src":this.m_lastTruffleResult.imageUrl
               }]
            };
            Global.farmSocialNetwork.publishFeedStory("PigpenFoundTruffle",bundleData,[this.m_lastTruffleResult.friendUid],false);
         }
         else
         {
            FarmStatsManager.count("pigpenv2","huntActive","getTruffle","clickCancel");
         }
         this.m_lastTruffleResult = null;
      }
   }
}

