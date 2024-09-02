using {app.db as db} from '../db/data-model';

using { API_SALES_ORDER_SRV } from './external/API_SALES_ORDER_SRV.csn';

using { API_BUSINESS_PARTNER } from './external/API_BUSINESS_PARTNER.csn';

using { RCMCandidate } from './external/RCMCandidate.csn';

service CatalogService @(path : '/catalog')
@(requires: 'authenticated-user')
{
    entity Sales
      @(restrict: [{ grant: ['READ'],
                     to: 'Viewer'
                   },
                   { grant: ['WRITE'],
                     to: 'Admin' 
                   }
                  ])
      as select * from db.Sales
      actions {
        @(restrict: [{ to: 'Viewer' }])
        function largestOrder() returns String;
        @(restrict: [{ to: 'Admin' }])
        action boost();
      }
    ;

    function topSales
      @(restrict: [{ to: 'Viewer' }])
      (amount: Integer)
      returns many Sales;

    @readonly
    entity SalesOrders
      @(restrict: [{ to: 'Viewer' }])
      as projection on API_SALES_ORDER_SRV.A_SalesOrder {
          SalesOrder,
          SalesOrganization,
          DistributionChannel,
          SoldToParty,
          IncotermsLocation1,
          TotalNetAmount,
          TransactionCurrency
        };


    @readonly
    entity BusinessPartners
      @(restrict: [{ to: 'Viewer' }])
      as projection on API_BUSINESS_PARTNER.A_BusinessPartner {
          BusinessPartner,
          Customer,
          FirstName,
          LastName,
          CorrespondenceLanguage
        };

    @readonly
    entity Candidates
      @(restrict: [{ to: 'Viewer' }])
      as projection on RCMCandidate.Candidate {
          candidateId,
          firstName,
          lastName,
          cellPhone,
          city,
          zip,
          country
        };


    type userRoles { identified: Boolean; authenticated: Boolean; Viewer: Boolean; Admin: Boolean; };
    type user { user: String; locale: String; roles: userRoles; };
    function userInfo() returns user;
};
