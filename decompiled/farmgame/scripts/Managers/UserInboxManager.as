package Managers
{
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Managers.Clubs.DataObjects.FarmClubDataObject;
   import Managers.Clubs.FarmClubDataManager;
   import Widgets.Windows.Clubs.FarmClubReportWindow;
   
   public class UserInboxManager
   {
      
      public function UserInboxManager()
      {
         super();
      }
      
      public static function onTransactionComplete(event:TransactionEvent) : void
      {
         var userInboxUpdates:Array = null;
         var userInboxUpdate:Object = null;
         var farmClubData:FarmClubDataObject = null;
         var callbackIndex:int = 0;
         if(Boolean(event && event.transaction) && Boolean(event.transaction.rawResult) && Boolean(event.transaction.rawResult["metadata"]) && Boolean(event.transaction.rawResult.metadata["UserInbox"]))
         {
            userInboxUpdates = event.transaction.rawResult.metadata.UserInbox;
            if(userInboxUpdates != null)
            {
               for each(userInboxUpdate in userInboxUpdates)
               {
                  if(userInboxUpdate == null)
                  {
                     continue;
                  }
                  if(!userInboxUpdate["type"])
                  {
                     continue;
                  }
                  switch(userInboxUpdate.type)
                  {
                     case "clubReport":
                        if(userInboxUpdate.clubReportSuccess == true)
                        {
                           farmClubData = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
                           if(farmClubData == null)
                           {
                              callbackIndex = 0;
                              callbackIndex = FarmClubDataManager.getInstance().registerCaller(FarmClubDataManager.FARM_CLUB_DATA,function(data:FarmClubDataObject):void
                              {
                                 FarmClubDataManager.getInstance().unregisterCaller(callbackIndex);
                                 UI.displayPopup(new FarmClubReportWindow(userInboxUpdate,data));
                              });
                           }
                           else
                           {
                              UI.displayPopup(new FarmClubReportWindow(userInboxUpdate,farmClubData));
                           }
                        }
                  }
               }
            }
         }
      }
   }
}

