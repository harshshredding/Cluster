import 'package:CoffeeShop/proposals.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  group('ListOfProposals', () {
    test('size returns zero right after initialization', () {
      final ListOfProposals listOfProposals = ListOfProposals();
      expect(listOfProposals.size(), 0);
    });
    test('all isFavorite() calls return false after initialization', () {
      final ListOfProposals listOfProposals = ListOfProposals();
      expect(listOfProposals.isFavorite(null), false);
      expect(listOfProposals.isFavorite('a'), false);
      expect(listOfProposals.isFavorite('aasds'), false);
      expect(listOfProposals.isFavorite('aasdasd'), false);
    });
    test('all proposalExists() calls return false after initialization', () {
      final ListOfProposals listOfProposals = ListOfProposals();
      expect(listOfProposals.proposalExists(null), false);
      expect(listOfProposals.proposalExists('a'), false);
      expect(listOfProposals.proposalExists('aasds'), false);
      expect(listOfProposals.proposalExists('aasdasd'), false);
    });
    test('Add proposals works as expected', () {
      final ListOfProposals listOfProposals = ListOfProposals();

      MockDocumentSnapshot snapshot1 = new  MockDocumentSnapshot();
      when(snapshot1.documentID).thenAnswer((_) => '1');
      when(snapshot1.data).thenAnswer((_) => <String, dynamic>{"created": Timestamp.fromDate(DateTime.utc(2018))});

      MockDocumentSnapshot snapshot2 = new  MockDocumentSnapshot();
      when(snapshot2.documentID).thenAnswer((_) => '2');
      when(snapshot2.data).thenAnswer((_) => <String, dynamic>{"created": Timestamp.fromDate(DateTime.utc(2019))});

      MockDocumentSnapshot snapshot3 = new  MockDocumentSnapshot();
      when(snapshot3.documentID).thenAnswer((_) => '3');
      when(snapshot3.data).thenAnswer((_) => <String, dynamic>{"created": Timestamp.fromDate(DateTime.utc(2020))});

      listOfProposals.addProposal(snapshot1);
      listOfProposals.addProposal(snapshot2);
      listOfProposals.addProposal(snapshot3);

      expect(listOfProposals.proposalExists('1'), true);
      expect(listOfProposals.proposalExists('2'), true);
      expect(listOfProposals.proposalExists('3'), true);

      expect(listOfProposals.size(), 3);

      Timestamp t1 = listOfProposals.get(0).data['created'];
      Timestamp t2 = listOfProposals.get(1).data['created'];
      Timestamp t3 = listOfProposals.get(2).data['created'];

      // We should expect a descending order
      expect(t1.compareTo(Timestamp.fromDate(DateTime.utc(2020))), 0);
      expect(t2.compareTo(Timestamp.fromDate(DateTime.utc(2019))), 0);
      expect(t3.compareTo(Timestamp.fromDate(DateTime.utc(2018))), 0);
    });
  });
}