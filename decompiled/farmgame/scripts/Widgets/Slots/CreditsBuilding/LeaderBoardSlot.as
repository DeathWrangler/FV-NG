package Widgets.Slots.CreditsBuilding
{
   import Classes.RewardCreditsBuilding;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class LeaderBoardSlot extends ZwSlotFrame
   {
      
      protected static const PROPERTIES_FILE_NAME:String = "Dialogs";
      
      protected static const USER_ICON_SIZE:Number = 39;
      
      protected static const USER_ICON_OFFSET_X:Number = 1;
      
      protected static const USER_ICON_OFFSET_Y:Number = 1;
      
      protected var m_featureName:String;
      
      public function LeaderBoardSlot(element:DisplayObject, featureName:String)
      {
         super(element);
         this.m_featureName = featureName;
         addWidget(new ZwTextField(m_element.rank_tf));
         addWidget(new ZwTextField(m_element.name_tf));
         addWidget(new ZwTextField(m_element.points_tf));
         addWidget(new ZwTextField(m_element.title_tf));
         var userIcon:FarmIcon = new FarmIcon(m_element.icon);
         userIcon.setIconSize(USER_ICON_SIZE,USER_ICON_SIZE);
         userIcon.x += USER_ICON_OFFSET_X;
         userIcon.y += USER_ICON_OFFSET_Y;
         addWidget(userIcon);
      }
      
      override public function populate(data:Object) : void
      {
         var strPK:String = null;
         var scorePK:String = null;
         var itemPK:String = null;
         var iconURL:String = null;
         var userIcon:FarmIcon = null;
         super.populate(data);
         var textField:ZwTextField = null;
         if(data.rank)
         {
            textField = getWidget(m_element.rank_tf) as ZwTextField;
            strPK = RewardCreditsBuilding.getLocalizedKey(this.m_featureName,"LeaderboardRank");
            if("" == strPK)
            {
               strPK = "RewardCreditsBuilding:LeaderboardRank";
            }
            textField.text = ZLocUtils.t_pk(strPK,null,{"rankNum":data.rank});
            textField.visible = true;
         }
         if(data.name)
         {
            textField = getWidget(m_element.name_tf) as ZwTextField;
            textField.text = data.name;
            textField.visible = true;
         }
         if(data.creditsReceived != null)
         {
            textField = getWidget(m_element.points_tf) as ZwTextField;
            scorePK = RewardCreditsBuilding.getLocalizedKey(this.m_featureName,"Score");
            itemPK = RewardCreditsBuilding.getCreditItemFriendlyName(this.m_featureName);
            if("" == scorePK)
            {
               scorePK = "Dialogs:RewardCredits_Score";
            }
            textField.text = ZLocUtils.t_pk(scorePK,null,{
               "quantity":data.creditsReceived,
               "creditName":ZLocUtils.tk_pk(itemPK,"",data.creditsReceived)
            });
            textField.visible = true;
         }
         if(data.title)
         {
            textField = getWidget(m_element.title_tf) as ZwTextField;
            textField.text = data.title;
            textField.visible = true;
         }
         if(data.uid)
         {
            iconURL = FarmGameUtil.getFriendIconByUid(data.uid);
            userIcon = getWidget(m_element.icon) as FarmIcon;
            userIcon.loadIcon(iconURL);
            userIcon.visible = true;
         }
      }
      
      override public function clearView() : void
      {
         hideAllWidgets();
      }
   }
}

