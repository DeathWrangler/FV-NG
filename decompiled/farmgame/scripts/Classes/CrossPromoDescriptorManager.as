package Classes
{
   import Classes.Constants.CrossPromoConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   
   public class CrossPromoDescriptorManager
   {
      
      private static const HOLDOUT_EXPERIMENT:String = "fv_xpromo_holdout";
      
      private static const HOLDOUT_EXPERIMENT_VARIANT:int = 3;
      
      private static const SEEN_TOASTER_POSTFIX:String = "_seen_toaster";
      
      private static const SEEN_REMOVE_BILLBOARD_POSTFIX:String = "_removeBillboard";
      
      private var m_crossPromoXml:XML = null;
      
      private var m_crossPromoData:Array = null;
      
      private var m_validPromos:Object = null;
      
      private var m_npcXML:XML = null;
      
      public function CrossPromoDescriptorManager()
      {
         super();
      }
      
      private static function createSeenToasterString(crossPromoDescriptor:CrossPromoDescriptor, postfix:String) : String
      {
         return crossPromoDescriptor.promoName + postfix;
      }
      
      public static function setToasterSeenFlag(crossPromoDescriptor:CrossPromoDescriptor) : void
      {
         Global.player.setSeenFlag(createSeenToasterString(crossPromoDescriptor,SEEN_TOASTER_POSTFIX));
      }
      
      public static function getToasterSeenFlag(crossPromoDescriptor:CrossPromoDescriptor) : Boolean
      {
         return Global.player.getSeenFlag(createSeenToasterString(crossPromoDescriptor,SEEN_TOASTER_POSTFIX));
      }
      
      public static function setRemoveBillboardSeenFlag(crossPromoDescriptor:CrossPromoDescriptor) : void
      {
         Global.player.setSeenFlag(createSeenToasterString(crossPromoDescriptor,SEEN_REMOVE_BILLBOARD_POSTFIX));
      }
      
      public static function getRemoveBillboardSeenFlag(crossPromoDescriptor:CrossPromoDescriptor) : Boolean
      {
         return Global.player.getSeenFlag(createSeenToasterString(crossPromoDescriptor,SEEN_REMOVE_BILLBOARD_POSTFIX));
      }
      
      public function setCrossPromoXml(crossPromoXml:XML) : void
      {
         if(this.m_validPromos != null)
         {
            FarmGameUtil.reportClientLog("Error: Cannot set cross promo xml after valid cross promos have been determined. - Not sure why we need to throw an error here -  setCrossPromoXml");
         }
         else
         {
            this.m_crossPromoXml = crossPromoXml;
         }
      }
      
      public function setCrossPromoData(crossPromoData:Array) : void
      {
         if(this.m_validPromos != null)
         {
            FarmGameUtil.reportClientLog("Error: Cannot set cross promo xml after valid cross promos have been determined. - Not sure why we need to throw an error here - setCrossPromoData");
         }
         else
         {
            this.m_crossPromoData = crossPromoData;
         }
      }
      
      private function evaluateValidCrossPromos() : void
      {
         var cpObj:Object = null;
         var gameDescriptor:CrossPromoDescriptor = null;
         this.m_validPromos = new Object();
         if(this.m_crossPromoData)
         {
            for each(cpObj in this.m_crossPromoData)
            {
               gameDescriptor = this.fromCrossPromoGame(cpObj);
               this.addCrossPromo(gameDescriptor);
            }
         }
         if(this.m_crossPromoXml)
         {
            this.parseXml(this.m_crossPromoXml);
         }
         this.m_crossPromoXml = null;
         this.m_crossPromoData = null;
      }
      
      public function get crossPromos() : Object
      {
         if(this.m_validPromos == null)
         {
            this.evaluateValidCrossPromos();
         }
         return this.m_validPromos;
      }
      
      public function getCrossPromo(promoName:String) : CrossPromoDescriptor
      {
         return this.crossPromos[promoName];
      }
      
      public function isCrossPromoActive(promoName:String) : Boolean
      {
         return this.getCrossPromo(promoName) != null;
      }
      
      private function addCrossPromo(gameDescriptor:CrossPromoDescriptor) : void
      {
         this.m_validPromos[gameDescriptor.promoName] = gameDescriptor;
      }
      
      private function parseXml(xml:XML) : void
      {
         var crosspromoXML:XML = null;
         var fromZCrossPromoId:String = null;
         var crossPromo:CrossPromoDescriptor = null;
         for each(crosspromoXML in xml.crosspromo)
         {
            fromZCrossPromoId = crosspromoXML.@fromZCrossPromoId;
            if(fromZCrossPromoId.length > 0 || Global.experimentManager.getExperimentVariant(HOLDOUT_EXPERIMENT) != HOLDOUT_EXPERIMENT_VARIANT)
            {
               crossPromo = this.createCrossPromoFromXml(crosspromoXML);
               if(crossPromo != null)
               {
                  if(fromZCrossPromoId.length > 0)
                  {
                     if(this.isCrossPromoActive(fromZCrossPromoId))
                     {
                        this.getCrossPromo(fromZCrossPromoId).combineWithDescriptor(crossPromo);
                     }
                  }
                  else
                  {
                     this.addCrossPromo(crossPromo);
                  }
               }
            }
         }
      }
      
      private function createCrossPromoFromXml(crosspromoXML:XML) : CrossPromoDescriptor
      {
         var preReqXML:XML = null;
         var prereq:Object = null;
         var experimentName:String = null;
         var toasterAsset:String = null;
         var toasterTitle:String = null;
         var toasterText:String = null;
         var toasterPlayUrl:String = null;
         var billboardItem:String = null;
         var billboardItemToolTip:String = null;
         var billboardPlayUrl:String = null;
         var npcId:String = null;
         var npcFriendImage:String = null;
         var npcPlayUrl:String = null;
         var dialogAsset:String = null;
         var dialogAcceptText:String = null;
         var dialogBodyText:String = null;
         var showCheckboxToRemoveItem:Boolean = false;
         var playUrl:String = null;
         var hudIconId:int = 0;
         var onClickRedirect:Boolean = false;
         var openInSameWindow:Boolean = false;
         var gameID:String = null;
         var promoName:String = null;
         var prereqXml:XML = null;
         var prereqs:Array = null;
         if(crosspromoXML.hasOwnProperty("prereqs"))
         {
            preReqXML = crosspromoXML.child("prereqs")[0];
            prereqs = PrerequisiteUtility.parseXmlNodePrereqs(preReqXML.prereq);
         }
         var result:CrossPromoDescriptor = null;
         var validPromo:Boolean = true;
         if(prereqs != null)
         {
            for each(prereq in prereqs)
            {
               if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
               {
                  validPromo = false;
                  break;
               }
            }
         }
         if(validPromo)
         {
            experimentName = null;
            if(prereqs != null)
            {
               for each(prereqXml in crosspromoXML.prereqs[0].prereq)
               {
                  if(prereqXml.@type == "experiment")
                  {
                     experimentName = prereqXml.@value;
                     break;
                  }
               }
            }
            toasterAsset = "";
            toasterTitle = "";
            toasterText = "";
            toasterPlayUrl = null;
            if(crosspromoXML.toaster.length() != 0)
            {
               if(experimentName == null || this.checkXMLExperimentVariants(experimentName,crosspromoXML.toaster[0]))
               {
                  toasterAsset = crosspromoXML.toaster[0].asset[0];
                  toasterText = crosspromoXML.toaster[0].toasterText[0];
                  toasterTitle = crosspromoXML.toaster[0].toasterTitle[0];
                  toasterPlayUrl = crosspromoXML.toaster[0].playUrl[0];
               }
            }
            billboardItem = "";
            billboardItemToolTip = "";
            billboardPlayUrl = null;
            if(crosspromoXML.billboard.length() != 0)
            {
               if(experimentName == null || this.checkXMLExperimentVariants(experimentName,crosspromoXML.billboard[0]))
               {
                  billboardItem = crosspromoXML.billboard[0].itemname[0];
                  billboardItemToolTip = crosspromoXML.billboard[0].toolTip[0];
                  if(billboardItemToolTip != null)
                  {
                     billboardItemToolTip = this.getZlocStringFromKey(billboardItemToolTip);
                  }
                  billboardPlayUrl = crosspromoXML.billboard[0].playUrl[0];
               }
            }
            npcId = "-1";
            npcFriendImage = null;
            npcPlayUrl = null;
            if(crosspromoXML.npc.length() != 0)
            {
               if(experimentName == null || this.checkXMLExperimentVariants(experimentName,crosspromoXML.npc[0]))
               {
                  npcId = crosspromoXML.npc.@id;
                  this.m_npcXML = crosspromoXML.npc[0];
                  npcFriendImage = this.getRandomNPCImage();
                  npcPlayUrl = crosspromoXML.npc[0].playUrl[0];
               }
            }
            dialogAsset = "";
            dialogAcceptText = "";
            dialogBodyText = "";
            showCheckboxToRemoveItem = true;
            playUrl = "";
            if(crosspromoXML.dialog.length() != 0)
            {
               dialogAsset = crosspromoXML.dialog[0].asset[0];
               dialogAcceptText = crosspromoXML.dialog[0].accepttextkey[0];
               if(dialogAcceptText != null)
               {
                  dialogAcceptText = this.getZlocStringFromKey(dialogAcceptText);
               }
               dialogBodyText = crosspromoXML.dialog[0].bodyText[0];
               if(dialogBodyText != null)
               {
                  dialogBodyText = this.getZlocStringFromKey(dialogBodyText);
               }
               playUrl = crosspromoXML.dialog[0].playUrl[0];
               showCheckboxToRemoveItem = crosspromoXML.dialog[0].showCheckBoxToRemoveItem[0] == "true";
            }
            hudIconId = CrossPromoConstants.NOT_DEFINED;
            if(crosspromoXML.hudIcon.length() != 0)
            {
               if(experimentName == null || this.checkXMLExperimentVariants(experimentName,crosspromoXML.hudIcon[0]))
               {
                  hudIconId = int(crosspromoXML.hudIcon[0].iconId[0]);
               }
            }
            onClickRedirect = false;
            if("@onClickRedirect" in crosspromoXML && crosspromoXML.@onClickRedirect == "true")
            {
               onClickRedirect = Boolean(crosspromoXML.@onClickRedirect);
            }
            openInSameWindow = false;
            if("@openInSameWindow" in crosspromoXML && crosspromoXML.@openInSameWindow == "true")
            {
               openInSameWindow = Boolean(crosspromoXML.@openInSameWindow);
            }
            gameID = crosspromoXML.@gameID;
            promoName = crosspromoXML.@name;
            result = new CrossPromoDescriptor(promoName,gameID,dialogAsset,dialogAcceptText,playUrl,billboardPlayUrl,npcPlayUrl,toasterPlayUrl,openInSameWindow,dialogBodyText,showCheckboxToRemoveItem,billboardItem,billboardItemToolTip,toasterAsset,npcId,npcFriendImage,toasterTitle,toasterText,hudIconId,onClickRedirect);
         }
         return result;
      }
      
      private function getZlocStringFromKey(key:String) : String
      {
         var keyParts:Array = key.split(":");
         return ZLocUtils.t(keyParts[0],keyParts[1]);
      }
      
      private function checkXMLExperimentVariants(experimentName:String, xml:XML) : Boolean
      {
         var variantsString:String = null;
         var experimentVariants:Array = null;
         var variant:String = null;
         var experimentPass:Boolean = false;
         if(Boolean(xml) && xml.@variants.length() > 0)
         {
            variantsString = xml.@variants;
            experimentVariants = variantsString.split(",");
            for each(variant in experimentVariants)
            {
               if(Global.experimentManager.getExperimentVariant(experimentName) == parseInt(variant))
               {
                  experimentPass = true;
                  break;
               }
            }
         }
         else
         {
            experimentPass = true;
         }
         return experimentPass;
      }
      
      private function fromCrossPromoGame(obj:Object) : CrossPromoDescriptor
      {
         var promoId:Number = Number(obj.promoId);
         var promoName:String = promoId.toString();
         var gameID:String = obj.gameId as String;
         var dialogAsset:String = obj.promoUIElements.popup_image as String;
         var dialogTextKey:String = obj.promoUIElements.popup_text as String;
         var dialogAcceptText:String = obj.promoUIElements.popup_btn_text;
         var playUrl:String = obj.promoUIElements.play_url;
         dialogAcceptText = "Dialogs:CastleVilleIncentivizedButtonText";
         dialogTextKey = "CastleVilleIncentivizedText";
         dialogAsset = "assets/dialogs/FV_BannerAd_xpromo_mafiawars2.swf";
         FarmStatsManager.count("zcrosspromo","crosspromo_" + promoId,"flash_impressions");
         return new CrossPromoDescriptor(promoName,gameID,dialogAsset,this.getZlocStringFromKey(dialogAcceptText),playUrl,null,null,null,false,this.getZlocStringFromKey(dialogTextKey));
      }
      
      public function getRandomNPCImage() : String
      {
         var result:String = "";
         if(this.m_npcXML != null)
         {
            if(this.m_npcXML.asset.length() == 1)
            {
               result = this.m_npcXML.asset[0];
            }
            else if(this.m_npcXML.asset.length() > 1)
            {
               result = this.m_npcXML.asset[Math.floor(Math.random() * this.m_npcXML.asset.length())];
            }
         }
         return result;
      }
   }
}

